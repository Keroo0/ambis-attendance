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

import '../../../../core/database/app_database.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../enrollment/data/repositories/face_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/services/geofence_settings_service.dart';
import '../providers/rate_limit_provider.dart';
import '../../../enrollment/presentation/providers/face_enrollment_provider.dart';

enum _LivenessState { waitingBlink, passed }

enum _LocationState { loading, ok, error }

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with TickerProviderStateMixin {
  // ── Camera ───────────────────────────────────────────────────────
  CameraController? _camCtrl;
  bool _camLoading = true;
  String? _camError;

  // ── GPS ──────────────────────────────────────────────────────────
  _LocationState _locState = _LocationState.loading;
  Position? _position;
  String _locMsg = 'Mendeteksi lokasi...';

  // ── Kind (auto-detected from today's record) ──────────────────────
  AttendanceKind _kind = AttendanceKind.checkIn;
  AttendanceEntity? _todayRecord;
  bool _recordLoading = true;
  bool _geofenceEnabled = true;

  bool get _allDone =>
      _todayRecord?.timeIn != null && _todayRecord?.timeOut != null;

  // ── Face scanning ────────────────────────────────────────────────
  bool _scanning = false;
  String _scanStatus = '';
  Color _scanColor = const Color(0xFF191C1E);
  _LivenessState _livenessState = _LivenessState.waitingBlink;
  int _failCount = 0;
  bool _handlingFailure = false;
  bool _frameBusy = false;

  Timer? _captureTimer;
  Timer? _livenessTimer;

  // ── Scan-line animation ───────────────────────────────────────────
  late final AnimationController _lineCtrl;
  late final Animation<double> _lineAnim;

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
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _lineAnim = Tween<double>(begin: 0, end: 1).animate(_lineCtrl);
    _initCamera();
    _initLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTodayRecord());
  }

  Future<void> _loadTodayRecord() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null || !mounted) {
      setState(() => _recordLoading = false);
      return;
    }
    final record = await ref
        .read(attendanceRepositoryProvider)
        .getTodayAttendance(user.id);
    if (!mounted) return;
    setState(() {
      _todayRecord = record;
      _recordLoading = false;
      if (record == null) {
        _kind = AttendanceKind.checkIn;
      } else if (record.timeOut == null) {
        _kind = AttendanceKind.checkOut;
      }
      // timeIn + timeOut both set → _allDone = true, kind unused
    });
  }

  // ── Camera init ───────────────────────────────────────────────────

  Future<void> _initCamera() async {
    if (kIsWeb) {
      setState(() {
        _camLoading = false;
        _camError = 'Kamera tidak tersedia di browser.';
      });
      return;
    }
    final perm = await Permission.camera.request();
    if (!perm.isGranted) {
      setState(() {
        _camLoading = false;
        _camError = 'Izin kamera ditolak.';
      });
      return;
    }
    try {
      final cameras = await availableCameras();
      final ctrl = CameraController(
        pickFrontCamera(cameras),
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _camCtrl = ctrl;
        _camLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _camLoading = false;
        _camError = 'Gagal inisialisasi kamera: $e';
      });
    }
  }

  // ── Location init ─────────────────────────────────────────────────

  Future<void> _initLocation() async {
    if (!mounted) return;
    setState(() {
      _locState = _LocationState.loading;
      _locMsg = 'Mendeteksi lokasi...';
    });
    try {
      final settings = await ref.read(geofenceSettingsProvider.future);
      if (!mounted) return;
      setState(() => _geofenceEnabled = settings.enabled);

      if (!settings.enabled) {
        setState(() {
          _locState = _LocationState.ok;
          _locMsg = 'Lokasi absensi dinonaktifkan (bypass)';
        });
        return;
      }

      final loc = ref.read(locationServiceProvider);
      final pos = await loc.getCurrentPosition();
      if (!mounted) return;

      if (LocationService.isMocked(pos)) {
        setState(() {
          _locState = _LocationState.error;
          _locMsg = 'Mock GPS terdeteksi';
        });
        return;
      }

      final dist = LocationService.haversineMeters(
        pos.latitude,
        pos.longitude,
        settings.lat,
        settings.lng,
      );

      if (dist > settings.radius) {
        setState(() {
          _locState = _LocationState.error;
          _locMsg =
              '${dist.toStringAsFixed(0)} m dari sekolah (maks ${settings.radius.toStringAsFixed(0)} m)';
        });
        return;
      }

      setState(() {
        _position = pos;
        _locState = _LocationState.ok;
        _locMsg = 'SMAN 07 Tangerang area';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locState = _LocationState.error;
        _locMsg = 'Gagal mendapatkan lokasi';
      });
    }
  }

  // ── Submit handler ────────────────────────────────────────────────

  Future<void> _onSubmit() async {
    if (_scanning || _frameBusy) return;

    final rl = ref.read(rateLimitProvider.notifier);
    final cd = rl.cooldownSecondsLeft();
    if (cd > 0) {
      _snack('Tunggu $cd detik sebelum absen lagi.');
      return;
    }
    final lk = rl.lockSecondsLeft();
    if (lk > 0) {
      _snack(
          'Terlalu banyak percobaan. Coba lagi dalam ${(lk / 60).ceil()} menit.',
          isError: true);
      return;
    }

    if (kIsWeb) {
      _snack('Fitur scan wajah tidak tersedia di browser.');
      return;
    }

    if (_locState != _LocationState.ok) {
      _snack('Pastikan lokasi Anda berada di area sekolah.', isError: true);
      return;
    }
    if (_geofenceEnabled && _position == null) {
      _snack('Lokasi belum berhasil dideteksi. Coba lagi.', isError: true);
      return;
    }

    try {
      await ref.read(attendanceRepositoryProvider).assertWithinTimeWindow(_kind);
    } on AppException catch (e) {
      _snack(e.message, isError: true);
      return;
    }

    setState(() {
      _scanning = true;
      _failCount = 0;
      _handlingFailure = false;
      _livenessState = _LivenessState.waitingBlink;
    });
    _startCapture();
  }

  // ── Capture loop ──────────────────────────────────────────────────

  void _startCapture() {
    _captureTimer?.cancel();
    _livenessTimer?.cancel();

    _setStatus('Kedipkan mata Anda', const Color(0xFFF5B800));
    _livenessTimer = Timer(
      const Duration(seconds: 8),
      () => _fail('Kedipan tidak terdeteksi. Coba lagi.'),
    );
    _captureTimer = Timer.periodic(
      const Duration(milliseconds: 400),
      (_) => _tick(),
    );
  }

  Future<void> _tick() async {
    if (_frameBusy) return;
    final ctrl = _camCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    _frameBusy = true;

    XFile? shot;
    try {
      shot = await ctrl.takePicture();
      final faces = await _detector.processImage(
        mlk.InputImage.fromFilePath(shot.path),
      );
      if (_livenessState == _LivenessState.waitingBlink) {
        _checkBlink(faces);
      } else {
        await _checkFace(faces, shot.path);
      }
    } catch (e) {
      _fail('Gagal: $e');
    } finally {
      if (shot != null) {
        try {
          await File(shot.path).delete();
        } catch (_) {}
      }
      _frameBusy = false;
    }
  }

  void _checkBlink(List<mlk.Face> faces) {
    if (faces.length != 1) return;
    final f = faces.first;
    final l = f.leftEyeOpenProbability;
    final r = f.rightEyeOpenProbability;
    if (l != null && r != null && l < 0.3 && r < 0.3) {
      _livenessTimer?.cancel();
      setState(() => _livenessState = _LivenessState.passed);
      _setStatus('Liveness OK, mencocokkan wajah...', const Color(0xFF006A63));
    }
  }

  Future<void> _checkFace(List<mlk.Face> faces, String path) async {
    if (faces.isEmpty) {
      _setStatus('Wajah tidak terdeteksi', const Color(0xFFF5B800));
      return;
    }
    if (faces.length > 1) {
      _setStatus('Pastikan hanya satu wajah', const Color(0xFFF5B800));
      return;
    }
    final f = faces.first;
    if (!_frontal(f)) {
      _setStatus('Hadap lurus ke kamera', const Color(0xFFF5B800));
      return;
    }
    final faceRepo = ref.read(faceRepositoryProvider);
    final emb = await faceRepo.extractEmbeddingFromFile(
      File(path),
      faceBox: _expand(f.boundingBox, 1.2),
    );
    await _commit(emb);
  }

  bool _frontal(mlk.Face f) {
    final y = f.headEulerAngleY?.abs() ?? 99;
    final p = f.headEulerAngleX?.abs() ?? 99;
    final r = f.headEulerAngleZ?.abs() ?? 99;
    return y < 12 && p < 12 && r < 12;
  }

  Rect _expand(Rect r, double s) {
    final cx = r.left + r.width / 2;
    final cy = r.top + r.height / 2;
    return Rect.fromLTWH(cx - r.width * s / 2, cy - r.height * s / 2,
        r.width * s, r.height * s);
  }

  Future<void> _commit(Float32List emb) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;
    _captureTimer?.cancel();
    _livenessTimer?.cancel();
    _setStatus('Menyimpan...', const Color(0xFF191C1E));

    try {
      await ref.read(attendanceRepositoryProvider).recordAttendance(
            studentId: user.id,
            kind: _kind,
            capturedEmbedding: emb,
            position: _position,
          );
      ref.read(rateLimitProvider.notifier).recordSuccess();
      if (!mounted) return;
      final successMsg = _kind == AttendanceKind.checkIn
          ? 'Berhasil absen masuk!'
          : 'Berhasil absen pulang!';
      _setStatus(successMsg, const Color(0xFF006A63));
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      context.go('/dashboard');
    } on AppException catch (e) {
      if (!mounted) return;
      _fail(e.message);
    } catch (e) {
      if (!mounted) return;
      _fail('Gagal: $e');
    }
  }

  void _fail(String msg) {
    if (_handlingFailure) return;
    _handlingFailure = true;
    _captureTimer?.cancel();
    _livenessTimer?.cancel();
    ref.read(rateLimitProvider.notifier).recordFailure();
    _failCount++;
    _setStatus(msg, Colors.red);

    if (_failCount >= 3) {
      Future.microtask(() {
        if (mounted) _showFallback();
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _handlingFailure = false;
        setState(() => _livenessState = _LivenessState.waitingBlink);
        _startCapture();
      });
    }
  }

  void _showFallback() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Verifikasi Gagal'),
        content: const Text(
            'Silakan hubungi guru untuk validasi manual kehadiran Anda.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _failCount = 0;
                _livenessState = _LivenessState.waitingBlink;
                _handlingFailure = false;
                _scanning = false;
                _scanStatus = '';
              });
            },
            child: const Text('Coba Lagi',
                style: TextStyle(color: Color(0xFF006A63))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Minta Validasi Guru',
                style: TextStyle(color: Color(0xFFF5B800))),
          ),
        ],
      ),
    );
  }

  void _setStatus(String s, Color c) {
    if (!mounted) return;
    setState(() {
      _scanStatus = s;
      _scanColor = c;
    });
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : null,
    ));
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _livenessTimer?.cancel();
    _lineCtrl.dispose();
    _camCtrl?.dispose();
    _detector.close();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_scanning && _locState == _LocationState.ok;

    final user = ref.watch(authProvider).valueOrNull;
    final enrolledAsync = user != null
        ? ref.watch(hasEnrolledFaceProvider(user.id))
        : const AsyncValue<bool>.data(false);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: enrolledAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
              child: Text('Gagal memeriksa status pendaftaran wajah')),
          data: (enrolled) {
            if (!enrolled) {
              return _NotEnrolledView(
                onRegister: () => context.push('/enrollment'),
              );
            }
            if (_recordLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_allDone) {
              return _AllDoneView(
                timeIn: _todayRecord!.timeIn!,
                timeOut: _todayRecord!.timeOut!,
                onHome: () => context.go('/dashboard'),
              );
            }
            return Column(
              children: [
                // ── TopBar ───────────────────────────────────────────────
                Container(
                  height: 64,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (context.canPop())
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFF002B5B)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      const Icon(Icons.school_rounded,
                          color: Color(0xFF002B5B), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'SMAN 07 Tangerang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF001736),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined,
                            color: Color(0xFF002B5B)),
                      ),
                    ],
                  ),
                ),

                // ── Content ──────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Camera viewfinder
                        _Viewfinder(
                          controller: _camCtrl,
                          loading: _camLoading,
                          error: _camError,
                          lineAnim: _lineAnim,
                        ),

                        const SizedBox(height: 12),

                        // Check-in / Check-out time cards
                        _TimeCardRow(
                          timeIn: _todayRecord?.timeIn,
                          timeOut: _todayRecord?.timeOut,
                        ),

                        const SizedBox(height: 12),

                        // Status bar
                        _StatusBar(
                          locState: _locState,
                          locMsg: _locMsg,
                          scanning: _scanning,
                          scanStatus: _scanStatus,
                          scanColor: _scanColor,
                          onRetry: _locState == _LocationState.error
                              ? _initLocation
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: canSubmit ? _onSubmit : null,
                            icon: _scanning
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Icon(Icons.login, size: 20),
                            label: Text(
                              _scanning
                                  ? 'Sedang Memverifikasi...'
                                  : _kind == AttendanceKind.checkIn
                                      ? 'Konfirmasi Check-In'
                                      : 'Konfirmasi Check-Out',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF1565C0).withAlpha(100),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── All-done view ──────────────────────────────────────────────────────────

class _AllDoneView extends StatelessWidget {
  const _AllDoneView({
    required this.timeIn,
    required this.timeOut,
    required this.onHome,
  });

  final String timeIn;
  final String timeOut;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF006A63).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 48, color: Color(0xFF006A63)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Presensi Hari Ini Selesai',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF001736),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E3E5)),
              ),
              child: Column(
                children: [
                  _TimeRow(icon: Icons.login_rounded, label: 'Masuk', time: timeIn),
                  const SizedBox(height: 8),
                  _TimeRow(icon: Icons.logout_rounded, label: 'Pulang', time: timeOut),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001736),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kembali ke Beranda',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.icon,
    required this.label,
    required this.time,
  });

  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF43474F)),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF43474F))),
        const Spacer(),
        Text(
          time.length >= 5 ? time.substring(0, 5) : time,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF001736),
          ),
        ),
      ],
    );
  }
}

// ── Camera viewfinder ──────────────────────────────────────────────────────

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.controller,
    required this.loading,
    required this.error,
    required this.lineAnim,
  });

  final CameraController? controller;
  final bool loading;
  final String? error;
  final Animation<double> lineAnim;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6E8EA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF7F9FB), width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF001736).withAlpha(20),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera or state
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              _CameraErrorView(message: error!)
            else
              LayoutBuilder(
                builder: (_, box) {
                  final ctrl = controller!;
                  final a = ctrl.value.aspectRatio;
                  final size = box.maxWidth;
                  // Cover the 1:1 square without distortion
                  final w = a >= 1.0 ? size * a : size;
                  final h = a >= 1.0 ? size : size / a;
                  return ClipRect(
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: w,
                        height: h,
                        child: CameraPreview(ctrl),
                      ),
                    ),
                  );
                },
              ),

            // Scan line
            if (!loading && error == null)
              LayoutBuilder(
                builder: (_, box) => AnimatedBuilder(
                  animation: lineAnim,
                  builder: (_, __) => Stack(
                    children: [
                      Positioned(
                        top: box.maxHeight * lineAnim.value - 20,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xCC47FBEB),
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

            // Corner brackets
            const Positioned.fill(
              child: CustomPaint(painter: _CornerPainter()),
            ),

            // Info pill
            if (!loading && error == null)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.white, size: 13),
                        SizedBox(width: 5),
                        Text(
                          'Arahkan wajah ke kamera',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  size: 48, color: Color(0xFF747780)),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF43474F), height: 1.5),
              ),
            ],
          ),
        ),
      );
}

// ── Time card row ──────────────────────────────────────────────────────────

class _TimeCardRow extends StatelessWidget {
  const _TimeCardRow({required this.timeIn, required this.timeOut});

  final String? timeIn;
  final String? timeOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _TimeCard(label: 'Check-in', time: timeIn)),
        const SizedBox(width: 12),
        Expanded(child: _TimeCard(label: 'Check-out', time: timeOut)),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.label, required this.time});

  final String label;
  final String? time;

  String get _display {
    if (time == null) return '--:--';
    return time!.length >= 5 ? time!.substring(0, 5) : time!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF747780)),
          ),
          const SizedBox(height: 4),
          Text(
            _display,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191C1E),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status bar ─────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.locState,
    required this.locMsg,
    required this.scanning,
    required this.scanStatus,
    required this.scanColor,
    this.onRetry,
  });

  final _LocationState locState;
  final String locMsg;
  final bool scanning;
  final String scanStatus;
  final Color scanColor;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 10),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (locState == _LocationState.loading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF006A63),
        ),
      );
    }
    if (locState == _LocationState.error) {
      return const Icon(Icons.error_outline, color: Colors.red, size: 20);
    }
    if (scanning) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF006A63),
        ),
      );
    }
    return const Icon(Icons.face_retouching_natural,
        color: Color(0xFF006A63), size: 20);
  }

  Widget _buildContent() {
    if (locState == _LocationState.loading) {
      return const Text(
        'Mendeteksi lokasi...',
        style: TextStyle(fontSize: 13, color: Color(0xFF43474F)),
      );
    }
    if (locState == _LocationState.error) {
      return Row(
        children: [
          Expanded(
            child: Text(
              locMsg,
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006A63),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      );
    }
    if (scanning && scanStatus.isNotEmpty) {
      return Text(
        scanStatus,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: scanColor,
        ),
      );
    }
    return const Text(
      'Tekan tombol presensi untuk mencocokkan wajah',
      style: TextStyle(fontSize: 13, color: Color(0xFF43474F)),
    );
  }
}

// ── Corner brackets painter ────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF47FBEB)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const arm = 48.0;
    const pad = 16.0;
    const r = 8.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(pad, pad + arm)
        ..lineTo(pad, pad + r)
        ..arcToPoint(const Offset(pad + r, pad),
            radius: const Radius.circular(r))
        ..lineTo(pad + arm, pad),
      p,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - pad - arm, pad)
        ..lineTo(size.width - pad - r, pad)
        ..arcToPoint(Offset(size.width - pad, pad + r),
            radius: const Radius.circular(r))
        ..lineTo(size.width - pad, pad + arm),
      p,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(pad, size.height - pad - arm)
        ..lineTo(pad, size.height - pad - r)
        ..arcToPoint(Offset(pad + r, size.height - pad),
            radius: const Radius.circular(r), clockwise: false)
        ..lineTo(pad + arm, size.height - pad),
      p,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - pad - arm, size.height - pad)
        ..lineTo(size.width - pad - r, size.height - pad)
        ..arcToPoint(
            Offset(size.width - pad, size.height - pad - r),
            radius: const Radius.circular(r),
            clockwise: false)
        ..lineTo(size.width - pad, size.height - pad - arm),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Not Enrolled View ───────────────────────────────────────────────

class _NotEnrolledView extends StatelessWidget {
  const _NotEnrolledView({required this.onRegister});
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.face_retouching_off,
                  size: 64, color: Color(0xFF747780)),
              const SizedBox(height: 16),
              const Text('NISN ini belum terdaftar',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF191C1E))),
              const SizedBox(height: 8),
              const Text('Daftarkan wajah Anda untuk bisa absen',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF747780))),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRegister,
                icon: const Icon(Icons.app_registration),
                label: const Text('Daftar Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001736),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
}
