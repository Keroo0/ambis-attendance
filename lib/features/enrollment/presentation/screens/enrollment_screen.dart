import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/services/camera_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/enrollment_provider.dart';

class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  CameraController? _controller;
  bool _initializing = true;
  String? _initError;
  Timer? _captureTimer;
  bool _capturing = false;

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
            'Fitur kamera tidak tersedia di browser.\nGunakan aplikasi mobile untuk mendaftar wajah.';
      });
      return;
    }
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _initializing = false;
        _initError = 'Izin kamera ditolak.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      final front = pickFrontCamera(cameras);
      final controller = CameraController(
        front,
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
      _tickCapture();
    });
  }

  Future<void> _tickCapture() async {
    if (_capturing) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final state = ref.read(enrollmentControllerProvider);
    if (state.phase == EnrollmentPhase.saving ||
        state.phase == EnrollmentPhase.done) {
      return;
    }

    _capturing = true;
    XFile? shot;
    try {
      shot = await controller.takePicture();
      final reachedQuota = await ref
          .read(enrollmentControllerProvider.notifier)
          .processCapture(File(shot.path));
      if (reachedQuota) {
        _captureTimer?.cancel();
        await _finalize();
      }
    } catch (_) {
      // ignore single frame failures; loop continues
    } finally {
      // Cleanup the temporary file each iteration to keep cache lean.
      if (shot != null) {
        try {
          await File(shot.path).delete();
        } catch (_) {}
      }
      _capturing = false;
    }
  }

  Future<void> _finalize() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;
    try {
      await ref.read(enrollmentControllerProvider.notifier).finalize(user.id);
      if (!mounted) return;
      // Brief pause so user sees the success state.
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal simpan: $e')),
      );
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(enrollmentControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Wajah')),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : _initError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Text(
                      _initError!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(Spacing.borderRadius),
                        ),
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: state.samplesNeeded == 0
                                ? 0
                                : state.samplesCaptured /
                                    state.samplesNeeded,
                            backgroundColor:
                                AppColors.surface,
                            color: AppColors.secondary,
                            minHeight: 6,
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            state.statusText,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: Spacing.xs),
                            Text(
                              state.errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
