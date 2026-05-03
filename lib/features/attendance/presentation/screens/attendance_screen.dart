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
      // Mock-GPS detection: schema field exists; real check is Phase 2.
      // ignore: dead_code
      if (false && LocationService.isMocked(pos)) {
        throw const GeofenceException('Mock GPS terdeteksi.');
      }

      // 3. Open scanner.
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
                        style:
                            Theme.of(context).textTheme.bodyMedium,
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
