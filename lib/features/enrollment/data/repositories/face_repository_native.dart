import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/exceptions/app_exception.dart';

const String _modelAsset = 'assets/models/mobilefacenet.tflite';
const Uuid _uuid = Uuid();

class FaceRepository {
  FaceRepository(this._db);

  final AppDatabase _db;
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    if (_interpreter != null) return;

    // Reject the placeholder file we ship in Git so the failure surfaces
    // immediately instead of producing garbage embeddings on device.
    final asset = await rootBundle.load(_modelAsset);
    if (asset.lengthInBytes < 100 * 1024) {
      throw const ModelLoadException(
        'MobileFaceNet TFLite model belum dipasang. '
        'Letakkan file model (~5MB) di assets/models/mobilefacenet.tflite '
        'dan rebuild aplikasi.',
      );
    }

    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
    } catch (e) {
      throw ModelLoadException('Gagal load TFLite: $e');
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  /// Extract a 128-D L2-normalised embedding from a face image file.
  ///
  /// Pipeline: decode → optionally crop to [faceBox] → resize to 112×112 →
  /// normalise to [-1, 1] → tflite invoke → L2 normalise.
  Future<Float32List> extractEmbeddingFromFile(
    File imageFile, {
    Rect? faceBox,
  }) async {
    await loadModel();

    final raw = await imageFile.readAsBytes();
    final decoded = img.decodeImage(raw);
    if (decoded == null) {
      throw const ModelLoadException('Gambar tidak dapat di-decode.');
    }

    final cropped = faceBox != null
        ? img.copyCrop(
            decoded,
            x: faceBox.left.round().clamp(0, decoded.width - 1),
            y: faceBox.top.round().clamp(0, decoded.height - 1),
            width: faceBox.width
                .round()
                .clamp(1, decoded.width - faceBox.left.round()),
            height: faceBox.height
                .round()
                .clamp(1, decoded.height - faceBox.top.round()),
          )
        : decoded;

    final resized = img.copyResize(
      cropped,
      width: AppConstants.faceInputSize,
      height: AppConstants.faceInputSize,
      interpolation: img.Interpolation.linear,
    );

    return _runInference(resized);
  }

  Float32List _runInference(img.Image faceImg) {
    const size = AppConstants.faceInputSize;
    final input = List.generate(
      1,
      (_) => List.generate(
        size,
        (y) => List.generate(size, (x) {
          final pixel = faceImg.getPixel(x, y);
          return [
            (pixel.r - 127.5) / 127.5,
            (pixel.g - 127.5) / 127.5,
            (pixel.b - 127.5) / 127.5,
          ];
        }),
      ),
    );

    final output = List.filled(AppConstants.embeddingSize, 0.0)
        .reshape([1, AppConstants.embeddingSize]);

    _interpreter!.run(input, output);

    final embedding = Float32List.fromList(
      List<double>.from(output[0] as List),
    );
    return _l2Normalize(embedding);
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

  /// Average several embeddings into one centroid (used during enrollment
  /// to reduce single-frame noise).
  static Float32List averageEmbeddings(List<Float32List> embeddings) {
    if (embeddings.isEmpty) {
      throw ArgumentError('embeddings is empty');
    }
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

  /// Cosine similarity for L2-normalised vectors. Range: [-1, 1] but in
  /// practice embeddings are in [0, 1] for the same identity.
  static double cosineSimilarity(Float32List a, Float32List b) {
    assert(a.length == b.length, 'Embedding lengths differ');
    var dot = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  /// Persist (or replace) the active embedding for [studentId].
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

  Future<bool> hasActiveEmbedding(String userId) async {
    final query = _db.select(_db.faceEmbeddings)
      ..where((t) => t.studentId.equals(userId))
      ..where((t) => t.isActive.equals(true));
    final row = await query.getSingleOrNull();
    return row != null;
  }
}

final faceRepositoryProvider = Provider<FaceRepository>((ref) {
  final repo = FaceRepository(ref.watch(appDatabaseProvider));
  ref.onDispose(repo.dispose);
  return repo;
});
