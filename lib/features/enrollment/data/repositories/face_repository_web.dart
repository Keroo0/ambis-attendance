import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';

// TFLite is not available on web — this stub keeps the API identical so the
// rest of the app compiles. Methods that require the TFLite runtime throw
// UnsupportedError; database and pure-Dart methods work normally.

const Uuid _uuid = Uuid();

class FaceRepository {
  FaceRepository(this._db);

  final AppDatabase _db;

  Future<void> loadModel() async {
    throw UnsupportedError(
      'TFLite tidak tersedia di web. Gunakan aplikasi mobile untuk enrollment.',
    );
  }

  void dispose() {}

  Future<Float32List> extractEmbeddingFromFile(
    File imageFile, {
    Rect? faceBox,
  }) async {
    throw UnsupportedError(
      'Ekstraksi embedding wajah tidak tersedia di web.',
    );
  }

  static Float32List _l2Normalize(Float32List v) {
    var sum = 0.0;
    for (final x in v) {
      sum += x * x;
    }
    final norm = math.sqrt(sum);
    if (norm == 0) return v;
    final out = Float32List(v.length);
    for (var i = 0; i < v.length; i++) {
      out[i] = v[i] / norm;
    }
    return out;
  }

  static Float32List averageEmbeddings(List<Float32List> embeddings) {
    if (embeddings.isEmpty) throw ArgumentError('embeddings is empty');
    final n = embeddings.first.length;
    final acc = Float32List(n);
    for (final e in embeddings) {
      for (var i = 0; i < n; i++) {
        acc[i] += e[i];
      }
    }
    for (var i = 0; i < n; i++) {
      acc[i] /= embeddings.length;
    }
    return _l2Normalize(acc);
  }

  static double cosineSimilarity(Float32List a, Float32List b) {
    assert(a.length == b.length, 'Embedding lengths differ');
    var dot = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  Future<void> saveEmbedding(String studentId, Float32List embedding) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final blob = embedding.buffer.asUint8List();
    await _db.into(_db.faceEmbeddings).insertOnConflictUpdate(
          FaceEmbeddingsCompanion(
            id: drift.Value(_uuid.v4()),
            studentId: drift.Value(studentId),
            embedding: drift.Value(blob),
            enrollmentDate: drift.Value(now),
            updatedAt: drift.Value(now),
            isActive: const drift.Value(true),
          ),
        );
  }

  Future<Float32List?> getEmbedding(String studentId) async {
    final query = _db.select(_db.faceEmbeddings)
      ..where((t) => t.studentId.equals(studentId))
      ..where((t) => t.isActive.equals(true));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final bytes = row.embedding;
    return Float32List.view(
      Uint8List.fromList(bytes).buffer,
      0,
      AppConstants.embeddingSize,
    );
  }
}

final faceRepositoryProvider = Provider<FaceRepository>((ref) {
  final repo = FaceRepository(ref.watch(appDatabaseProvider));
  ref.onDispose(repo.dispose);
  return repo;
});
