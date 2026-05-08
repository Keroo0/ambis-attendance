import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as mlk;
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/camera_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../enrollment/data/repositories/face_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../providers/rate_limit_provider.dart';

enum _LivenessState { waitingBlink, waitingHeadTurn, passed }

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({
    super.key,
    required this.kind,
    required this.position,
  });

  final AttendanceKind kind;
  final Position position;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  CameraController? _controller;
  bool _initializing = true;
  String? _initError;
  Timer? _captureTimer;
  Timer? _livenessTimeoutTimer;
  bool _busy = false;
  String _status = 'Mempersiapkan kamera...';
  Color _statusColor = AppColors.darkTextPrimary;
  _LivenessState _livenessState = _LivenessState.waitingBlink;
  int _failCount = 0;
  bool _handlingFailure = false;

  // enableClassification: true diperlukan untuk leftEyeOpenProbability.
  late final mlk.FaceDetector _detector = mlk.FaceDetector(
    options: mlk.FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      performanceMode: mlk.FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (kIsWeb) {
      setState(() {
        _initializing = false;
        _initError =
            'Fitur scan wajah tidak tersedia di browser.\nGunakan aplikasi mobile untuk absen.';
      });
      return;
    }
    final perm = await Permission.camera.request();
    if (!perm.isGranted) {
      setState(() {
        _initializing = false;
        _initError = 'Izin kamera ditolak.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      final controller = CameraController(
        pickFrontCamera(cameras),
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
      _startCaptureLoop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _initError = 'Gagal inisialisasi kamera: $e';
      });
    }
  }

  void _startCaptureLoop() {
    _captureTimer?.cancel();
    _livenessTimeoutTimer?.cancel();

    if (_livenessState == _LivenessState.waitingBlink) {
      _setStatus('Kedipkan mata Anda', AppColors.darkWarning);
      _livenessTimeoutTimer = Timer(
        const Duration(seconds: 8),
        () => _handleFailure('Kedipan tidak terdeteksi. Coba lagi.'),
      );
    } else if (_livenessState == _LivenessState.waitingHeadTurn) {
      _setStatus('Tolehkan kepala ke kiri sebentar', AppColors.darkWarning);
      _livenessTimeoutTimer = Timer(
        const Duration(seconds: 6),
        () => _handleFailure('Gerakan kepala tidak terdeteksi. Coba lagi.'),
      );
    }

    // 400ms tick — cukup cepat untuk menangkap kedipan (durasi 150–400ms).
    _captureTimer = Timer.periodic(
      const Duration(milliseconds: 400),
      (_) => _tick(),
    );
  }

  Future<void> _tick() async {
    if (_busy) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    _busy = true;

    XFile? shot;
    try {
      shot = await controller.takePicture();
      final faces = await _detector.processImage(
        mlk.InputImage.fromFilePath(shot.path),
      );

      if (_livenessState == _LivenessState.waitingBlink) {
        _checkBlink(faces);
      } else if (_livenessState == _LivenessState.waitingHeadTurn) {
        _checkHeadTurn(faces);
      } else {
        await _checkFace(faces, shot.path);
      }
    } catch (e) {
      _handleFailure('Gagal: $e');
    } finally {
      if (shot != null) {
        try {
          await File(shot.path).delete();
        } catch (_) {}
      }
      _busy = false;
    }
  }

  /// Deteksi kedip: kedua mata tertutup (probabilitas < 0.3).
  void _checkBlink(List<mlk.Face> faces) {
    if (faces.length != 1) return;
    final face = faces.first;
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left != null && right != null && left < 0.3 && right < 0.3) {
      _livenessTimeoutTimer?.cancel();
      setState(() => _livenessState = _LivenessState.waitingHeadTurn);
      _startCaptureLoop();
    }
  }

  /// Deteksi toleh kepala: Euler Y > 25 derajat (kepala menghadap kiri).
  void _checkHeadTurn(List<mlk.Face> faces) {
    if (faces.length != 1) return;
    final face = faces.first;
    final yaw = face.headEulerAngleY;
    if (yaw != null && yaw.abs() > 25) {
      _livenessTimeoutTimer?.cancel();
      setState(() => _livenessState = _LivenessState.passed);
      _setStatus('Liveness OK, mencocokkan wajah...', AppColors.darkPrimary);
    }
  }

  /// Pencocokan wajah — dijalankan hanya setelah liveness lolos.
  Future<void> _checkFace(List<mlk.Face> faces, String imagePath) async {
    if (faces.isEmpty) {
      _setStatus('Wajah tidak terdeteksi', AppColors.darkWarning);
      return;
    }
    if (faces.length > 1) {
      _setStatus('Pastikan hanya satu wajah', AppColors.darkWarning);
      return;
    }
    final face = faces.first;
    if (!_isFrontal(face)) {
      _setStatus('Hadap lurus ke kamera', AppColors.darkWarning);
      return;
    }

    final faceRepo = ref.read(faceRepositoryProvider);
    final embedding = await faceRepo.extractEmbeddingFromFile(
      File(imagePath),
      faceBox: _expand(face.boundingBox, 1.2),
    );
    await _commit(embedding);
  }

  bool _isFrontal(mlk.Face f) {
    final yaw = f.headEulerAngleY?.abs() ?? 99;
    final pitch = f.headEulerAngleX?.abs() ?? 99;
    final roll = f.headEulerAngleZ?.abs() ?? 99;
    return yaw < 12 && pitch < 12 && roll < 12;
  }

  Rect _expand(Rect r, double scale) {
    final cx = r.left + r.width / 2;
    final cy = r.top + r.height / 2;
    return Rect.fromLTWH(
      cx - r.width * scale / 2,
      cy - r.height * scale / 2,
      r.width * scale,
      r.height * scale,
    );
  }

  Future<void> _commit(Float32List embedding) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;
    _captureTimer?.cancel();
    _livenessTimeoutTimer?.cancel();

    setState(() {
      _status = 'Menyimpan...';
      _statusColor = AppColors.darkTextPrimary;
    });

    try {
      await ref.read(attendanceRepositoryProvider).recordAttendance(
            studentId: user.id,
            kind: widget.kind,
            capturedEmbedding: embedding,
            position: widget.position,
          );
      ref.read(rateLimitProvider.notifier).recordSuccess();
      if (!mounted) return;
      setState(() {
        _status = widget.kind == AttendanceKind.checkIn
            ? 'Berhasil absen masuk!'
            : 'Berhasil absen pulang!';
        _statusColor = AppColors.darkSuccess;
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      context.go('/dashboard');
    } on AppException catch (e) {
      if (!mounted) return;
      _handleFailure(e.message);
    } catch (e) {
      if (!mounted) return;
      _handleFailure('Gagal: $e');
    }
  }

  void _handleFailure(String message) {
    if (_handlingFailure) return;
    _handlingFailure = true;
    _captureTimer?.cancel();
    _livenessTimeoutTimer?.cancel();

    ref.read(rateLimitProvider.notifier).recordFailure();
    _failCount++;

    _setStatus(message, AppColors.darkError);

    if (_failCount >= 3) {
      // Tampilkan dialog setelah frame selesai dirender.
      Future.microtask(() {
        if (mounted) _showFallbackDialog();
      });
    } else {
      // Reset ke blink pertama dan coba lagi setelah 2 detik.
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _handlingFailure = false;
        setState(() => _livenessState = _LivenessState.waitingBlink);
        _startCaptureLoop();
      });
    }
  }

  void _showFallbackDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Verifikasi Gagal',
          style: TextStyle(color: AppColors.darkTextPrimary),
        ),
        content: const Text(
          'Silakan hubungi guru untuk validasi manual kehadiran Anda.',
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _failCount = 0;
                _handlingFailure = false;
                _livenessState = _LivenessState.waitingBlink;
              });
              _startCaptureLoop();
            },
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: AppColors.darkSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // tutup dialog
              context.pop(); // kembali ke AttendanceScreen
            },
            child: const Text(
              'Minta Validasi Guru',
              style: TextStyle(color: AppColors.darkAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _setStatus(String s, Color c) {
    if (!mounted) return;
    setState(() {
      _status = s;
      _statusColor = c;
    });
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _livenessTimeoutTimer?.cancel();
    _controller?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.kind == AttendanceKind.checkIn
        ? 'Absen Masuk'
        : 'Absen Pulang';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : _initError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Text(_initError!, textAlign: TextAlign.center),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: _statusColor),
                      ),
                    ),
                  ],
                ),
    );
  }
}
