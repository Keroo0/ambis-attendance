import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as mlk;

import '../../data/repositories/face_repository.dart';

const int _kSamplesNeeded = 5;
const double _kEulerThresholdDeg = 12.0;

enum EnrollmentPhase { idle, capturing, saving, done, error }

class EnrollmentState {
  const EnrollmentState({
    this.phase = EnrollmentPhase.idle,
    this.samplesCaptured = 0,
    this.statusText = 'Posisikan wajah ke tengah bingkai',
    this.errorMessage,
  });

  final EnrollmentPhase phase;
  final int samplesCaptured;
  final String statusText;
  final String? errorMessage;

  int get samplesNeeded => _kSamplesNeeded;

  EnrollmentState copyWith({
    EnrollmentPhase? phase,
    int? samplesCaptured,
    String? statusText,
    String? errorMessage,
  }) {
    return EnrollmentState(
      phase: phase ?? this.phase,
      samplesCaptured: samplesCaptured ?? this.samplesCaptured,
      statusText: statusText ?? this.statusText,
      errorMessage: errorMessage,
    );
  }
}

class EnrollmentController extends StateNotifier<EnrollmentState> {
  EnrollmentController(this._faceRepo) : super(const EnrollmentState());

  final FaceRepository _faceRepo;

  final List<Float32List> _embeddings = [];
  final mlk.FaceDetector _detector = mlk.FaceDetector(
    options: mlk.FaceDetectorOptions(
      enableClassification: false,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: false,
      performanceMode: mlk.FaceDetectorMode.accurate,
    ),
  );

  /// Process a freshly captured still image. Returns true when enough
  /// samples have been collected (caller should then `finalize`).
  Future<bool> processCapture(File picture) async {
    if (state.phase == EnrollmentPhase.saving ||
        state.phase == EnrollmentPhase.done) {
      return false;
    }

    state = state.copyWith(phase: EnrollmentPhase.capturing);

    final input = mlk.InputImage.fromFilePath(picture.path);
    final faces = await _detector.processImage(input);

    if (faces.isEmpty) {
      state = state.copyWith(statusText: 'Wajah tidak terdeteksi');
      return false;
    }
    if (faces.length > 1) {
      state = state.copyWith(statusText: 'Pastikan hanya satu wajah');
      return false;
    }

    final face = faces.first;
    if (!_isFrontal(face)) {
      state = state.copyWith(
        statusText: 'Hadap lurus ke kamera',
      );
      return false;
    }

    try {
      final embedding = await _faceRepo.extractEmbeddingFromFile(
        picture,
        faceBox: _expandRect(face.boundingBox, scale: 1.2),
      );
      _embeddings.add(embedding);
      state = state.copyWith(
        samplesCaptured: _embeddings.length,
        statusText: 'Sampel ${_embeddings.length}/$_kSamplesNeeded — '
            'tahan posisi sebentar',
      );
    } catch (e) {
      state = state.copyWith(
        phase: EnrollmentPhase.error,
        errorMessage: e.toString(),
      );
      return false;
    }

    return _embeddings.length >= _kSamplesNeeded;
  }

  Future<void> finalize(String studentId) async {
    if (_embeddings.length < _kSamplesNeeded) {
      throw StateError('Belum cukup sampel');
    }
    state = state.copyWith(
      phase: EnrollmentPhase.saving,
      statusText: 'Menyimpan...',
    );
    final centroid = FaceRepository.averageEmbeddings(_embeddings);
    await _faceRepo.saveEmbedding(studentId, centroid);
    state = state.copyWith(
      phase: EnrollmentPhase.done,
      statusText: 'Berhasil! Wajah sudah terdaftar.',
    );
  }

  void reset() {
    _embeddings.clear();
    state = const EnrollmentState();
  }

  bool _isFrontal(mlk.Face face) {
    final yaw = face.headEulerAngleY?.abs() ?? 99;
    final pitch = face.headEulerAngleX?.abs() ?? 99;
    final roll = face.headEulerAngleZ?.abs() ?? 99;
    return yaw < _kEulerThresholdDeg &&
        pitch < _kEulerThresholdDeg &&
        roll < _kEulerThresholdDeg;
  }

  Rect _expandRect(Rect r, {double scale = 1.2}) {
    final cx = r.left + r.width / 2;
    final cy = r.top + r.height / 2;
    final w = r.width * scale;
    final h = r.height * scale;
    return Rect.fromLTWH(cx - w / 2, cy - h / 2, w, h);
  }

  @override
  void dispose() {
    _detector.close();
    super.dispose();
  }
}

final enrollmentControllerProvider =
    StateNotifierProvider.autoDispose<EnrollmentController, EnrollmentState>(
  (ref) => EnrollmentController(ref.watch(faceRepositoryProvider)),
);
