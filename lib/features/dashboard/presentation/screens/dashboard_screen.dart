import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../attendance/data/repositories/sync_repository.dart';
import '../../../attendance/presentation/providers/sync_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/data/dummy_notifications.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final pending = ref.watch(pendingSyncCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AMBIS'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (kUnreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$kUnreadNotificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              Text(
                'Halo, ${user?.fullname ?? 'Siswa'}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'NISN ${user?.nisn ?? '—'}  ·  Role ${user?.role ?? '—'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: Spacing.lg),
              _PrimaryAction(
                icon: Icons.fingerprint,
                title: 'Absen Sekarang',
                subtitle: 'Verifikasi wajah + GPS',
                onTap: () => context.push('/attendance'),
              ),
              const SizedBox(height: Spacing.sm),
              _SecondaryAction(
                icon: Icons.face_retouching_natural,
                title: 'Daftar Ulang Wajah',
                onTap: () => context.push('/enrollment'),
              ),
              const SizedBox(height: Spacing.sm),
              _SecondaryAction(
                icon: Icons.calendar_month_outlined,
                title: 'Riwayat Kehadiran',
                onTap: () => context.go('/history'),
              ),
              const SizedBox(height: Spacing.sm),
              _SecondaryAction(
                icon: Icons.description_outlined,
                title: 'Ajukan Izin / Sakit',
                onTap: () => context.push('/leave'),
              ),
              const SizedBox(height: Spacing.sm),
              _SyncCard(pending: pending, onSync: () async {
                final result = await ref
                    .read(syncCoordinatorProvider)
                    .triggerNow();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_summary(result)),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _summary(SyncResult r) {
    if (r.isEmpty) return 'Tidak ada data yang perlu disinkron.';
    return 'Sync selesai: ${r.synced} berhasil, ${r.failed} gagal.';
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Spacing.borderRadius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Icon(icon, size: 48, color: AppColors.textPrimary),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

class _SyncCard extends StatelessWidget {
  const _SyncCard({required this.pending, required this.onSync});
  final AsyncValue<int> pending;
  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) {
    final count = pending.valueOrNull ?? 0;
    return Card(
      child: ListTile(
        leading: Icon(
          count == 0 ? Icons.cloud_done : Icons.cloud_sync,
          color: count == 0 ? AppColors.success : AppColors.warning,
        ),
        title: Text(
          count == 0
              ? 'Semua data tersinkron'
              : '$count data menunggu sinkronisasi',
        ),
        trailing: TextButton(
          onPressed: onSync,
          child: const Text('Sync'),
        ),
      ),
    );
  }
}
