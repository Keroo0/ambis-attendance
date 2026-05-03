# Phase 2 Security Layer — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementasi empat kontrol keamanan Phase 2: deteksi liveness blink aktif, aktifkan pengecekan mock GPS, fallback dialog "Minta Validasi Guru" setelah 3x gagal wajah, dan rate limiting in-memory (cooldown 30 dtk + lockout 5 menit).

**Architecture:** State rate limiting disimpan in-memory di Riverpod `Notifier` (tidak persisten ke DB — reset saat app di-restart). Liveness menggunakan state machine 2-state (`waitingBlink → passed`) yang berjalan di tick loop 400ms, sebelum fase pencocokan wajah yang sudah ada. Setelah 3x gagal (`_failCount`), dialog fallback tampil; setelah 5x gagal kumulatif (`RateLimitNotifier.failCount`), `AttendanceScreen` memblokir percobaan selama 5 menit.

**Tech Stack:** Flutter, Riverpod (`Notifier`), Google ML Kit Face Detector (`enableClassification: true`), `dart:async Timer`

---

## Peta File

| File | Aksi | Tanggung Jawab |
|---|---|---|
| `lib/features/attendance/presentation/providers/rate_limit_provider.dart` | BUAT | State cooldown + lockout in-memory |
| `lib/core/exceptions/app_exception.dart` | MODIFIKASI | Tambah `LivenessException`, `RateLimitException` |
| `lib/features/attendance/presentation/screens/attendance_screen.dart` | MODIFIKASI | Cek rate limit + aktifkan mock GPS |
| `lib/features/attendance/presentation/screens/scanner_screen.dart` | MODIFIKASI | Liveness blink + fail counter + dialog fallback |
| `test/features/attendance/presentation/providers/rate_limit_provider_test.dart` | BUAT | Unit test RateLimitNotifier |

---

## Task 1: Tambah Tipe Exception Baru

**Files:**
- Modify: `lib/core/exceptions/app_exception.dart`

- [ ] **Langkah 1: Tambah dua exception ke app_exception.dart**

Tambahkan dua class berikut di akhir file `lib/core/exceptions/app_exception.dart` (setelah `SyncException`):

```dart
class LivenessException extends AppException {
  const LivenessException(super.message);
}

class RateLimitException extends AppException {
  const RateLimitException(super.message);
}
```

- [ ] **Langkah 2: Verifikasi compile**

```bash
cd ambis_attendance && flutter analyze lib/core/exceptions/app_exception.dart
```

Expected: `No issues found.`

- [ ] **Langkah 3: Commit**

```bash
git add lib/core/exceptions/app_exception.dart
git commit -m "feat(security): add LivenessException and RateLimitException types"
```

---

## Task 2: Buat RateLimitNotifier (TDD)

**Files:**
- Create: `lib/features/attendance/presentation/providers/rate_limit_provider.dart`
- Create: `test/features/attendance/presentation/providers/rate_limit_provider_test.dart`

- [ ] **Langkah 1: Buat direktori test**

```bash
mkdir -p ambis_attendance/test/features/attendance/presentation/providers
```

- [ ] **Langkah 2: Tulis test yang gagal dulu**

Buat `test/features/attendance/presentation/providers/rate_limit_provider_test.dart`:

```dart
import 'package:ambis_attendance/features/attendance/presentation/providers/rate_limit_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RateLimitNotifier', () {
    late ProviderContainer container;
    late RateLimitNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(rateLimitProvider.notifier);
    });

    tearDown(container.dispose);

    test('cooldown adalah 0 ketika belum ada sukses', () {
      expect(notifier.cooldownSecondsLeft(), 0);
    });

    test('cooldown positif segera setelah recordSuccess', () {
      notifier.recordSuccess();
      expect(notifier.cooldownSecondsLeft(), greaterThan(0));
    });

    test('tidak terkunci setelah 4 kegagalan', () {
      for (int i = 0; i < 4; i++) notifier.recordFailure();
      expect(notifier.lockSecondsLeft(), 0);
    });

    test('terkunci setelah 5 kegagalan', () {
      for (int i = 0; i < 5; i++) notifier.recordFailure();
      expect(notifier.lockSecondsLeft(), greaterThan(0));
    });

    test('recordSuccess mereset failCount dan menghapus lockout', () {
      for (int i = 0; i < 5; i++) notifier.recordFailure();
      notifier.recordSuccess();
      expect(notifier.lockSecondsLeft(), 0);
      expect(container.read(rateLimitProvider).failCount, 0);
    });

    test('failCount bertambah setiap kegagalan', () {
      notifier.recordFailure();
      notifier.recordFailure();
      expect(container.read(rateLimitProvider).failCount, 2);
    });
  });
}
```

- [ ] **Langkah 3: Jalankan test — pastikan gagal**

```bash
cd ambis_attendance && flutter test test/features/attendance/presentation/providers/rate_limit_provider_test.dart
```

Expected: Error `Target of URI doesn't exist` atau `Cannot find 'rateLimitProvider'`.

- [ ] **Langkah 4: Implementasi RateLimitNotifier**

Buat `lib/features/attendance/presentation/providers/rate_limit_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RateLimitState {
  const RateLimitState({
    this.lastSuccess,
    this.failCount = 0,
    this.lockedUntil,
  });

  final DateTime? lastSuccess;
  final int failCount;
  final DateTime? lockedUntil;
}

class RateLimitNotifier extends Notifier<RateLimitState> {
  @override
  RateLimitState build() => const RateLimitState();

  /// Sisa detik cooldown setelah sukses terakhir (0 = boleh lanjut).
  int cooldownSecondsLeft() {
    final last = state.lastSuccess;
    if (last == null) return 0;
    final elapsed = DateTime.now().difference(last).inSeconds;
    return (30 - elapsed).clamp(0, 30);
  }

  /// Sisa detik lockout (0 = tidak terkunci).
  int lockSecondsLeft() {
    final until = state.lockedUntil;
    if (until == null) return 0;
    return until.difference(DateTime.now()).inSeconds.clamp(0, 300);
  }

  void recordSuccess() {
    state = RateLimitState(lastSuccess: DateTime.now());
  }

  void recordFailure() {
    final newCount = state.failCount + 1;
    state = RateLimitState(
      lastSuccess: state.lastSuccess,
      failCount: newCount,
      lockedUntil: newCount >= 5
          ? DateTime.now().add(const Duration(minutes: 5))
          : state.lockedUntil,
    );
  }
}

final rateLimitProvider =
    NotifierProvider<RateLimitNotifier, RateLimitState>(RateLimitNotifier.new);
```

- [ ] **Langkah 5: Jalankan test — pastikan lulus**

```bash
cd ambis_attendance && flutter test test/features/attendance/presentation/providers/rate_limit_provider_test.dart
```

Expected:
```
00:00 +6: All tests passed!
```

- [ ] **Langkah 6: Commit**

```bash
git add lib/features/attendance/presentation/providers/rate_limit_provider.dart \
        test/features/attendance/presentation/providers/rate_limit_provider_test.dart
git commit -m "feat(security): add in-memory RateLimitNotifier with cooldown and lockout"
```

---

## Task 3: Modifikasi AttendanceScreen

**Files:**
- Modify: `lib/features/attendance/presentation/screens/attendance_screen.dart`

- [ ] **Langkah 1: Ganti seluruh isi attendance_screen.dart**

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/attendance_repository.dart';
import '../providers/rate_limit_provider.dart';
import 'scanner_screen.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  bool _busy = false;

  Future<void> _start(AttendanceKind kind) async {
    if (_busy) return;

    // Cek rate limit sebelum memulai proses apapun.
    final rl = ref.read(rateLimitProvider.notifier);
    final cooldown = rl.cooldownSecondsLeft();
    if (cooldown > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tunggu $cooldown detik sebelum absen lagi.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    final locked = rl.lockSecondsLeft();
    if (locked > 0) {
      final mins = (locked / 60).ceil();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terlalu banyak percobaan. Coba lagi dalam $mins menit.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _busy = true);

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fitur GPS & scan wajah tidak tersedia di browser. '
            'Gunakan aplikasi mobile.',
          ),
        ),
      );
      setState(() => _busy = false);
      return;
    }

    try {
      final repo = ref.read(attendanceRepositoryProvider);
      // 1. Time window.
      await repo.assertWithinTimeWindow(kind);

      // 2. GPS + geofence.
      final loc = ref.read(locationServiceProvider);
      final pos = await loc.getCurrentPosition();
      final distance = LocationService.distanceToSchool(pos);
      if (!LocationService.isWithinGeofence(pos)) {
        throw GeofenceException(
          'Lokasi Anda ${distance.toStringAsFixed(0)} m dari sekolah '
          '(maks 50 m).',
        );
      }
      // Mock GPS detection (Phase 2).
      if (LocationService.isMocked(pos)) {
        throw const GeofenceException(
          'Mock GPS terdeteksi. Nonaktifkan aplikasi pemalsuan lokasi.',
        );
      }

      // 3. Buka scanner.
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ScannerScreen(kind: kind, position: pos),
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Absensi')),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Halo, ${user?.fullname ?? ''}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: Spacing.xs),
                const Text(
                  'Pilih jenis absen. Pastikan Anda berada di area sekolah '
                  'dan dalam jam yang ditentukan.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: Spacing.lg),
                _ActionCard(
                  title: 'Absen Masuk',
                  subtitle: '06:00 – 07:30',
                  icon: Icons.login_rounded,
                  enabled: !_busy,
                  onTap: () => _start(AttendanceKind.checkIn),
                ),
                const SizedBox(height: Spacing.sm),
                _ActionCard(
                  title: 'Absen Pulang',
                  subtitle: '14:00 – 16:00',
                  icon: Icons.logout_rounded,
                  enabled: !_busy,
                  onTap: () => _start(AttendanceKind.checkOut),
                ),
                if (_busy) ...[
                  const SizedBox(height: Spacing.md),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.borderRadius),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Icon(icon, size: 40, color: AppColors.secondary),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Langkah 2: Verifikasi analyze**

```bash
cd ambis_attendance && flutter analyze lib/features/attendance/presentation/screens/attendance_screen.dart
```

Expected: `No issues found.`

- [ ] **Langkah 3: Commit**

```bash
git add lib/features/attendance/presentation/screens/attendance_screen.dart
git commit -m "feat(security): enable mock GPS detection and rate limit checks in AttendanceScreen"
```

---

## Task 4: Modifikasi ScannerScreen (Liveness + Fallback)

**Files:**
- Modify: `lib/features/attendance/presentation/screens/scanner_screen.dart`

- [ ] **Langkah 1: Ganti seluruh isi scanner_screen.dart**

```dart
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

enum _LivenessState { waitingBlink, passed }

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
  Color _statusColor = AppColors.textPrimary;
  _LivenessState _livenessState = _LivenessState.waitingBlink;
  int _failCount = 0;

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
      _setStatus('Kedipkan mata Anda', AppColors.warning);
      // Jika tidak ada kedipan dalam 8 detik, hitung sebagai kegagalan.
      _livenessTimeoutTimer = Timer(
        const Duration(seconds: 8),
        () => _handleFailure('Kedipan tidak terdeteksi. Coba lagi.'),
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
      } else {
        await _checkFace(faces, shot.path);
      }
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

  /// Deteksi kedip: kedua mata tertutup (probabilitas < 0.3).
  void _checkBlink(List<mlk.Face> faces) {
    if (faces.length != 1) return;
    final face = faces.first;
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left != null && right != null && left < 0.3 && right < 0.3) {
      _livenessTimeoutTimer?.cancel();
      setState(() => _livenessState = _LivenessState.passed);
      _setStatus('Liveness OK, mencocokkan wajah...', AppColors.primary);
    }
  }

  /// Pencocokan wajah — dijalankan hanya setelah liveness lolos.
  Future<void> _checkFace(List<mlk.Face> faces, String imagePath) async {
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
      _statusColor = AppColors.textPrimary;
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
        _statusColor = AppColors.success;
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
    _captureTimer?.cancel();
    _livenessTimeoutTimer?.cancel();

    ref.read(rateLimitProvider.notifier).recordFailure();
    _failCount++;

    _setStatus(message, AppColors.error);

    if (_failCount >= 3) {
      // Tampilkan dialog setelah frame selesai dirender.
      Future.microtask(() {
        if (mounted) _showFallbackDialog();
      });
    } else {
      // Reset ke fase liveness dan coba lagi setelah 2 detik.
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
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
        backgroundColor: AppColors.surface,
        title: const Text(
          'Verifikasi Gagal',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Silakan hubungi guru untuk validasi manual kehadiran Anda.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _failCount = 0;
                _livenessState = _LivenessState.waitingBlink;
              });
              _startCaptureLoop();
            },
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              Navigator.pop(context); // kembali ke AttendanceScreen
            },
            child: const Text(
              'Minta Validasi Guru',
              style: TextStyle(color: AppColors.accent),
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
```

- [ ] **Langkah 2: Verifikasi analyze**

```bash
cd ambis_attendance && flutter analyze lib/features/attendance/presentation/screens/scanner_screen.dart
```

Expected: `No issues found.`

- [ ] **Langkah 3: Commit**

```bash
git add lib/features/attendance/presentation/screens/scanner_screen.dart
git commit -m "feat(security): add blink liveness challenge, fail counter, and fallback dialog to ScannerScreen"
```

---

## Task 5: Verifikasi Akhir

- [ ] **Langkah 1: Jalankan semua test**

```bash
cd ambis_attendance && flutter test
```

Expected:
```
00:XX +12: All tests passed!
```

(6 test RateLimitNotifier baru + 6 test lama dari `widget_test.dart` = 12 total.)

- [ ] **Langkah 2: Jalankan flutter analyze seluruh project**

```bash
cd ambis_attendance && flutter analyze
```

Expected: `No issues found.`

- [ ] **Langkah 3: Checklist verifikasi manual (di perangkat Android)**

Karena ScannerScreen memerlukan kamera fisik, lakukan pengujian manual:

```
[ ] Buka AttendanceScreen → tap "Absen Masuk" → ScannerScreen muncul
[ ] Status awal: "Kedipkan mata Anda" (warna amber)
[ ] Kedipkan mata → status berubah ke "Liveness OK, mencocokkan wajah..."
[ ] Jika wajah cocok → "Berhasil absen masuk!" → redirect ke dashboard
[ ] Jika wajah tidak cocok → status merah → setelah 2 dtk reset ke "Kedipkan mata Anda"
[ ] Setelah 3x gagal → dialog "Verifikasi Gagal" muncul
[ ] Tap "Coba Lagi" → dialog tutup, kembali ke fase liveness
[ ] Tap "Minta Validasi Guru" → kembali ke AttendanceScreen
[ ] Setelah absen sukses → tap "Absen Masuk" lagi segera → snackbar cooldown muncul
[ ] Setelah 5x gagal kumulatif → snackbar lockout muncul di AttendanceScreen
```

- [ ] **Langkah 4: Commit final (jika ada perubahan minor dari testing)**

```bash
git add -p
git commit -m "chore(security): phase 2 security layer complete"
```
