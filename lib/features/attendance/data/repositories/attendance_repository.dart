import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../enrollment/data/repositories/face_repository.dart';

const Uuid _uuid = Uuid();

enum AttendanceKind { checkIn, checkOut }

Map<String, dynamic> buildFaceRecognitionLogPayload({
  required String studentId,
  String? attendanceId,
  String attemptType = 'genuine',
  String source = 'attendance',
  double? score,
  required double threshold,
  required bool passed,
  required bool livenessVerified,
  String? failureReason,
  int? durationMs,
  int? nowMs,
}) {
  return {
    'student_id': studentId,
    'attendance_id': attendanceId,
    'attempt_type': attemptType,
    'source': source,
    'face_match_score': score,
    'threshold': threshold,
    'passed': passed,
    'liveness_verified': livenessVerified,
    'failure_reason': failureReason,
    'duration_ms': durationMs,
    'created_at': nowMs ?? DateTime.now().millisecondsSinceEpoch,
  };
}

class AttendanceRepository {
  AttendanceRepository(this._supabase, this._faceRepo);

  final SupabaseClient _supabase;
  final FaceRepository _faceRepo;

  /// Fetches all settings from Supabase settings table as a key→value map.
  Future<Map<String, String>> _readSettings() async {
    try {
      final rows = await _supabase.from('settings').select('key, value');
      return {
        for (final r in (rows as List))
          (r as Map<String, dynamic>)['key'] as String:
              r['value'] as String? ?? '',
      };
    } catch (_) {
      return {};
    }
  }

  /// Checks the current time is within the configured window for [kind].
  /// Throws [TimeWindowException] if outside the window.
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

  /// Returns the face recognition threshold from Supabase settings.
  Future<double> readFaceThreshold() async {
    final settings = await _readSettings();
    return double.tryParse(settings['face_recognition_threshold'] ?? '') ??
        AppConstants.defaultFaceThreshold;
  }

  /// Records attendance by verifying face and writing directly to Supabase.
  /// Returns the upserted Supabase row as a [Map<String, dynamic>].
  Future<Map<String, dynamic>> recordAttendance({
    required String studentId,
    required AttendanceKind kind,
    required Float32List capturedEmbedding,
    Position? position,
    String? deviceId,
  }) async {
    final stopwatch = Stopwatch()..start();

    // 1. Compare face embeddings.
    final stored = await _faceRepo.getEmbedding(studentId);
    if (stored == null) {
      throw const FaceNotEnrolledException(
        'Wajah belum terdaftar. Lakukan enrolment terlebih dahulu.',
      );
    }
    final score = FaceRepository.cosineSimilarity(capturedEmbedding, stored);
    final threshold = await readFaceThreshold();
    if (score < threshold) {
      stopwatch.stop();
      await _insertFaceRecognitionLog(
        buildFaceRecognitionLogPayload(
          studentId: studentId,
          score: score,
          threshold: threshold,
          passed: false,
          livenessVerified: true,
          failureReason: 'face_mismatch',
          durationMs: stopwatch.elapsedMilliseconds,
        ),
      );
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
    final epoch = now.millisecondsSinceEpoch;

    // 3. Fetch existing row for today (if any).
    final existing = await getTodayAttendance(studentId);
    final attendanceId = existing?['id'] as String? ?? _uuid.v4();

    // 4. Build the upsert payload.
    final payload = <String, dynamic>{
      'id': attendanceId,
      'student_id': studentId,
      'date': today,
      'time_in': kind == AttendanceKind.checkIn
          ? timeStr
          : (existing?['time_in'] as String?),
      'time_out': kind == AttendanceKind.checkOut
          ? timeStr
          : (existing?['time_out'] as String?),
      'status': 'present',
      'is_within_geofence': withinGeofence,
      'liveness_verified': true,
      'face_match_score': score,
      'location_lat': position?.latitude,
      'location_lng': position?.longitude,
      'device_id': deviceId,
      'notes': null,
      'created_at': existing?['created_at'] as int? ?? epoch,
      'updated_at': epoch,
    };

    // 5. Upsert to Supabase.
    final result =
        await _supabase.from('attendance').upsert(payload).select().single();

    stopwatch.stop();
    await _insertFaceRecognitionLog(
      buildFaceRecognitionLogPayload(
        studentId: studentId,
        attendanceId: result['id'] as String?,
        score: score,
        threshold: threshold,
        passed: true,
        livenessVerified: true,
        durationMs: stopwatch.elapsedMilliseconds,
      ),
    );

    return result;
  }

  Future<void> _insertFaceRecognitionLog(Map<String, dynamic> payload) async {
    try {
      await _supabase.from('face_recognition_logs').insert(payload);
    } catch (_) {
      // Accuracy logging must never block attendance.
    }
  }

  /// Returns today's attendance row for the given student, or null.
  Future<Map<String, dynamic>?> getTodayAttendance(String studentId) async {
    final today = DateFormatter.dateOnly(DateTime.now());
    final rows = await _supabase
        .from('attendance')
        .select()
        .eq('student_id', studentId)
        .eq('date', today)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    return list.first as Map<String, dynamic>;
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(
    Supabase.instance.client,
    ref.watch(faceRepositoryProvider),
  );
});
