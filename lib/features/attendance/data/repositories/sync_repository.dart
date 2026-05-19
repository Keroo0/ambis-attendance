import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/database/app_database.dart';

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
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(
    ref.watch(appDatabaseProvider),
    sb.Supabase.instance.client,
  );
});
