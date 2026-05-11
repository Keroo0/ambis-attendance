import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../enrollment/data/repositories/face_repository.dart';

const Uuid _uuid = Uuid();

enum AttendanceKind { checkIn, checkOut }

class AttendanceRepository {
  AttendanceRepository(this._db, this._faceRepo);

  final AppDatabase _db;
  final FaceRepository _faceRepo;

  /// Looks up settings + system time. Throws [TimeWindowException] when
  /// [kind] falls outside the configured window.
  Future<void> assertWithinTimeWindow(AttendanceKind kind) async {
    final settings = await _readSettings();
    final start = kind == AttendanceKind.checkIn
        ? (settings['time_in_start'] ?? AppConstants.defaultTimeInStart)
        : (settings['time_out_start'] ?? AppConstants.defaultTimeOutStart);
    final end = kind == AttendanceKind.checkIn
        ? (settings['time_in_end'] ?? AppConstants.defaultTimeInEnd)
        : (settings['time_out_end'] ?? AppConstants.defaultTimeOutEnd);

    final now = DateFormatter.nowAsDuration();
    if (!DateFormatter.isWithinWindow(now, start, end)) {
      throw TimeWindowException(
        kind == AttendanceKind.checkIn
            ? 'Absen masuk hanya tersedia $start–$end.'
            : 'Absen pulang hanya tersedia $start–$end.',
      );
    }
  }

  Future<double> readFaceThreshold() async {
    final settings = await _readSettings();
    return double.tryParse(settings['face_recognition_threshold'] ?? '') ??
        AppConstants.defaultFaceThreshold;
  }

  /// Persists an attendance row + sync-queue row for [kind]. Returns the
  /// newly created or updated [AttendanceEntity].
  Future<AttendanceEntity> recordAttendance({
    required String studentId,
    required AttendanceKind kind,
    required Float32List capturedEmbedding,
    Position? position,
    String? deviceId,
  }) async {
    // 1. Compare embeddings.
    final stored = await _faceRepo.getEmbedding(studentId);
    if (stored == null) {
      throw const FaceNotEnrolledException(
        'Wajah belum terdaftar. Lakukan enrolment terlebih dahulu.',
      );
    }
    final score = FaceRepository.cosineSimilarity(capturedEmbedding, stored);
    final threshold = await readFaceThreshold();
    if (score < threshold) {
      throw FaceMismatchException(
        'Wajah tidak cocok (skor ${score.toStringAsFixed(2)}). '
        'Coba lagi dengan pencahayaan lebih baik.',
        score: score,
      );
    }

    // 2. Geofence check — skipped when geofence is disabled (position == null).
    final withinGeofence =
        position != null && LocationService.isWithinGeofence(position);
    if (position != null && !withinGeofence) {
      throw GeofenceException(
        'Anda berada di luar radius sekolah '
        '(${LocationService.distanceToSchool(position).toStringAsFixed(0)} m).',
      );
    }

    final now = DateTime.now();
    final today = DateFormatter.dateOnly(now);
    final timeStr = DateFormatter.timeOnly(now);

    // 3. Upsert attendance row (UNIQUE student_id + date).
    final existing = await (_db.select(_db.attendance)
          ..where((a) => a.studentId.equals(studentId))
          ..where((a) => a.date.equals(today)))
        .getSingleOrNull();

    final attendanceId = existing?.id ?? _uuid.v4();
    final epoch = now.millisecondsSinceEpoch;

    final row = AttendanceCompanion(
      id: drift.Value(attendanceId),
      studentId: drift.Value(studentId),
      date: drift.Value(today),
      timeIn: kind == AttendanceKind.checkIn
          ? drift.Value(timeStr)
          : drift.Value(existing?.timeIn),
      timeOut: kind == AttendanceKind.checkOut
          ? drift.Value(timeStr)
          : drift.Value(existing?.timeOut),
      status: const drift.Value('present'),
      isWithinGeofence: drift.Value(withinGeofence),
      // TODO(phase2): wire real liveness challenge result.
      livenessVerified: const drift.Value(true),
      faceMatchScore: drift.Value(score),
      locationLat: drift.Value(position?.latitude),
      locationLng: drift.Value(position?.longitude),
      deviceId: drift.Value(deviceId),
      notes: const drift.Value(null),
      syncedAt: const drift.Value(null),
      createdAt: drift.Value(existing?.createdAt ?? epoch),
      updatedAt: drift.Value(epoch),
    );

    await _db.into(_db.attendance).insertOnConflictUpdate(row);

    final saved = await (_db.select(_db.attendance)
          ..where((a) => a.id.equals(attendanceId)))
        .getSingle();

    // 4. Enqueue for sync.
    await _enqueue(saved, action: existing == null ? 'create' : 'update');

    return saved;
  }

  Future<void> _enqueue(
    AttendanceEntity row, {
    required String action,
  }) async {
    final payload = jsonEncode({
      'id': row.id,
      'student_id': row.studentId,
      'date': row.date,
      'time_in': row.timeIn,
      'time_out': row.timeOut,
      'status': row.status,
      'is_within_geofence': row.isWithinGeofence,
      'liveness_verified': row.livenessVerified,
      'face_match_score': row.faceMatchScore,
      'location_lat': row.locationLat,
      'location_lng': row.locationLng,
      'device_id': row.deviceId,
      'notes': row.notes,
      'created_at': row.createdAt,
      'updated_at': row.updatedAt,
    });

    await _db.into(_db.attendanceQueue).insert(
          AttendanceQueueCompanion(
            id: drift.Value(_uuid.v4()),
            attendanceId: drift.Value(row.id),
            studentId: drift.Value(row.studentId),
            action: drift.Value(action),
            payload: drift.Value(payload),
            status: const drift.Value('pending'),
            retryCount: const drift.Value(0),
            errorMessage: const drift.Value(null),
            createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
            syncedAt: const drift.Value(null),
          ),
        );
  }

  Future<Map<String, String>> _readSettings() async {
    final rows = await _db.select(_db.settings).get();
    return {for (final r in rows) r.key: r.value};
  }

  /// Today's attendance row for the given student (or null).
  Future<AttendanceEntity?> getTodayAttendance(String studentId) {
    final today = DateFormatter.dateOnly(DateTime.now());
    return (_db.select(_db.attendance)
          ..where((a) => a.studentId.equals(studentId))
          ..where((a) => a.date.equals(today)))
        .getSingleOrNull();
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(faceRepositoryProvider),
  );
});
