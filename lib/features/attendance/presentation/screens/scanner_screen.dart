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
  bool _busy = false;
  String _status = 'Posisikan wajah ke tengah bingkai';
  Color _statusColor = AppColors.textPrimary;

  late final mlk.FaceDetector _detector = mlk.FaceDetector(
    options: mlk.FaceDetectorOptions(
      enableClassification: false,
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
    _captureTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      _tick();
    });
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
      if (faces.isEmpty) {
        _setStatus('Wajah tidak terdeteksi', AppColors.warning);
        return;
      }
      if (faces.length > 1) {
        _setStatus('Pastikan hanya satu wajah', AppColors.warning);
        return;
      }
      final face = faces.first;
      if (!_isFrontal(face)) {
        _setStatus('Hadap lurus ke kamera', AppColors.warning);
        return;
      }

      final faceRepo = ref.read(faceRepositoryProvider);
      final embedding = await faceRepo.extractEmbeddingFromFile(
        File(shot.path),
        faceBox: _expand(face.boundingBox, 1.2),
      );
      await _commit(embedding);
    } catch (e) {
      _setStatus('Gagal: $e', AppColors.error);
    } finally {
      if (shot != null) {
        try {
          await File(shot.path).delete();
        } catch (_) {}
      }
      _busy = false;
    }
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

    setState(() {
      _status = 'Menyimpan...';
      _statusColor = AppColors.textPrimary;
    });

    try {
      await ref.read(attendanceRepositoryProvider).recordAttendance(
            studentId: user.id,
            kind: widget.kind,
            capturedEmbedding: embedding,
            position: widget.position,
          );
      if (!mounted) return;
      setState(() {
        _status = widget.kind == AttendanceKind.checkIn
            ? 'Berhasil absen masuk!'
            : 'Berhasil absen pulang!';
        _statusColor = AppColors.success;
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      context.go('/dashboard');
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = e.message;
        _statusColor = AppColors.error;
      });
      // Allow user to retry after a short pause.
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      _startCaptureLoop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Gagal: $e';
        _statusColor = AppColors.error;
      });
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      _startCaptureLoop();
    }
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
