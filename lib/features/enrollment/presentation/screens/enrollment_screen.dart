import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/services/camera_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/enrollment_provider.dart';

class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({super.key, this.guestUserId});

  /// When set, enrollment runs without a logged-in session (NISN-verify flow).
  final String? guestUserId;

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  bool _initializing = true;
  String? _initError;
  Timer? _captureTimer;
  bool _capturing = false;

  late final AnimationController _scanAnimCtrl;
  late final Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _scanAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_scanAnimCtrl);
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
      if (shot != null) {
        try {
          await File(shot.path).delete();
        } catch (_) {}
      }
      _capturing = false;
    }
  }

  Future<void> _finalize() async {
    final guestUserId = widget.guestUserId;
    final userId = guestUserId ?? ref.read(authProvider).valueOrNull?.id;
    if (userId == null) return;

    try {
      await ref.read(enrollmentControllerProvider.notifier).finalize(userId);
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      if (guestUserId != null) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: const Text('Wajah Berhasil Didaftarkan!'),
          description: const Text('Silakan login untuk melanjutkan.'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
        context.go('/login');
      } else {
        context.go('/dashboard');
      }
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
    _scanAnimCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(enrollmentControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blobs
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD6E3FF).withAlpha(80),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF47FBEB).withAlpha(40),
                ),
              ),
            ),

            Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/welcome'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFECEEF0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: Color(0xFF191C1E),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Registrasi Wajah',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF191C1E),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Presensi Biometrik',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF43474F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // "Ubah NISN" link
                TextButton(
                  onPressed: () => context.go('/nisn-verify'),
                  child: const Text(
                    'Ubah NISN',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF006A63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // ── Main content ────────────────────────────────────
                Expanded(
                  child: _initializing
                      ? const Center(child: CircularProgressIndicator())
                      : _initError != null
                          ? _buildError()
                          : _buildCamera(state),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Color(0xFFC4C6D0),
              ),
              const SizedBox(height: 16),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF43474F),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildCamera(EnrollmentState state) {
    final progress = state.samplesNeeded == 0
        ? 0.0
        : state.samplesCaptured / state.samplesNeeded;
    final isDone = state.phase == EnrollmentPhase.saving ||
        state.phase == EnrollmentPhase.done;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Posisikan wajah Anda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF002B5B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pastikan wajah Anda berada di dalam lingkaran dan pencahayaan cukup.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF43474F),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Circular viewfinder
          SizedBox(
            width: 256,
            height: 256,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF47FBEB).withAlpha(100),
                      width: 2,
                    ),
                  ),
                ),
                // Camera preview clipped to circle
                ClipOval(
                  child: SizedBox.square(
                    dimension: 240,
                    child: _controller != null
                        ? CameraPreview(_controller!)
                        : Container(color: const Color(0xFFECEEF0)),
                  ),
                ),
                // Scanning animation overlay
                if (!isDone)
                  ClipOval(
                    child: SizedBox.square(
                      dimension: 240,
                      child: AnimatedBuilder(
                        animation: _scanAnim,
                        builder: (_, __) => Stack(
                          children: [
                            Positioned(
                              top: 240 * _scanAnim.value - 30,
                              left: 0,
                              right: 0,
                              height: 40,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color(0x2047FBEB),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Reticle tick marks
                CustomPaint(
                  size: const Size(256, 256),
                  painter: _ReticlePainter(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFECEEF0),
              color: const Color(0xFF006A63),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),

          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFECEEF0),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color(0xFFC4C6D0).withAlpha(80),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDone ? Icons.check_circle_rounded : Icons.face_rounded,
                  size: 18,
                  color: isDone
                      ? const Color(0xFF006A63)
                      : const Color(0xFF002B5B),
                ),
                const SizedBox(width: 8),
                Text(
                  state.statusText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF191C1E),
                  ),
                ),
              ],
            ),
          ),

          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: const TextStyle(fontSize: 13, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],

          const Spacer(),

          // "Ambil Foto" button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isDone ? null : _tickCapture,
              icon: Icon(
                isDone
                    ? Icons.check_rounded
                    : Icons.photo_camera_rounded,
                size: 22,
              ),
              label: Text(
                isDone ? 'Menyimpan...' : 'Ambil Foto',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001736),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF001736).withAlpha(120),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF006A63)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const tickLen = 16.0;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Top
    canvas.drawLine(Offset(cx, 0), Offset(cx, tickLen), paint);
    // Bottom
    canvas.drawLine(Offset(cx, size.height), Offset(cx, size.height - tickLen), paint);
    // Left
    canvas.drawLine(Offset(0, cy), Offset(tickLen, cy), paint);
    // Right
    canvas.drawLine(Offset(size.width, cy), Offset(size.width - tickLen, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
