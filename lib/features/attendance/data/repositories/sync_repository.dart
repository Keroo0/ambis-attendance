import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/database/app_database.dart';

const int _kMaxRetries = 3;

class SyncResult {
  const SyncResult({required this.synced, required this.failed});
  final int synced;
  final int failed;

  bool get isEmpty => synced == 0 && failed == 0;
}

class SyncRepository {
  SyncRepository(this._db, this._supabase) : _log = Logger();

  final AppDatabase _db;
  final sb.SupabaseClient _supabase;
  final Logger _log;

  bool _running = false;

  /// Drains all `pending` rows in `attendance_queue`. Safe to call
  /// concurrently — a re-entrant invocation returns early.
  Future<SyncResult> syncPendingAttendance() async {
    if (_running) return const SyncResult(synced: 0, failed: 0);
    if (_supabase.auth.currentSession == null) {
      // Not signed in — nothing we can sync.
      return const SyncResult(synced: 0, failed: 0);
    }
    _running = true;

    var synced = 0;
    var failed = 0;
    try {
      final pending = await (_db.select(_db.attendanceQueue)
            ..where((q) => q.status.equals('pending')))
          .get();

      for (final item in pending) {
        try {
          final payload =
              jsonDecode(item.payload) as Map<String, dynamic>;
          // Upsert by primary key — id is the same uuid both sides.
          await _supabase.from('attendance').upsert(payload);

          await (_db.update(_db.attendanceQueue)
                ..where((q) => q.id.equals(item.id)))
              .write(
            AttendanceQueueCompanion(
              status: const drift.Value('synced'),
              syncedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
              errorMessage: const drift.Value(null),
            ),
          );
          await (_db.update(_db.attendance)
                ..where((a) => a.id.equals(item.attendanceId)))
              .write(
            AttendanceCompanion(
              syncedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
            ),
          );
          synced++;
        } catch (e, st) {
          _log.w('Sync row ${item.id} failed', error: e, stackTrace: st);
          final next = item.retryCount + 1;
          await (_db.update(_db.attendanceQueue)
                ..where((q) => q.id.equals(item.id)))
              .write(
            AttendanceQueueCompanion(
              retryCount: drift.Value(next),
              status: drift.Value(
                next >= _kMaxRetries ? 'failed' : 'pending',
              ),
              errorMessage: drift.Value(e.toString()),
            ),
          );
          failed++;
        }
      }
    } finally {
      _running = false;
    }
    return SyncResult(synced: synced, failed: failed);
  }

  /// Syncs face embeddings that were saved offline (syncedToSupabase = false).
  Future<SyncResult> syncPendingFaceEmbeddings() async {
    if (_supabase.auth.currentSession == null) {
      return const SyncResult(synced: 0, failed: 0);
    }

    var synced = 0;
    var failed = 0;

    final pending = await (_db.select(_db.faceEmbeddings)
          ..where((t) => t.syncedToSupabase.equals(false)))
        .get();

    for (final row in pending) {
      try {
        // Convert Uint8List blob back to List<double> for Supabase (float4[]).
        final floats =
            Float32List.view(Uint8List.fromList(row.embedding).buffer);
        await _supabase.from('face_embeddings').upsert({
          'id': row.id,
          'student_id': row.studentId,
          'embedding': floats.toList(),
          'enrollment_date': row.enrollmentDate,
          'updated_at': row.updatedAt,
          'is_active': row.isActive,
        });

        await (_db.update(_db.faceEmbeddings)
              ..where((t) => t.id.equals(row.id)))
            .write(
          const FaceEmbeddingsCompanion(
            syncedToSupabase: drift.Value(true),
          ),
        );
        synced++;
      } catch (e, st) {
        _log.w('Face embedding sync ${row.id} failed', error: e, stackTrace: st);
        failed++;
      }
    }

    return SyncResult(synced: synced, failed: failed);
  }

  /// Number of queue rows with [status] (use for badges / dashboards).
  Future<int> countByStatus(String status) async {
    final count = _db.attendanceQueue.id.count();
    final row = await (_db.selectOnly(_db.attendanceQueue)
          ..addColumns([count])
          ..where(_db.attendanceQueue.status.equals(status)))
        .getSingle();
    return row.read(count) ?? 0;
  }
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(
    ref.watch(appDatabaseProvider),
    sb.Supabase.instance.client,
  );
});

/// Number of pending sync rows — `ref.watch` from the dashboard for a
/// live badge.
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(syncRepositoryProvider).countByStatus('pending');
});
