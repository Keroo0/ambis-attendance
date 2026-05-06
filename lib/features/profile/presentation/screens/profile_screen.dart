import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final _profileStudentProvider =
    FutureProvider.autoDispose<StudentEntity?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.students)
        ..where((s) => s.id.equals(user.id)))
      .getSingleOrNull();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final studentAsync = ref.watch(_profileStudentProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onNotification: () => context.push('/notifications')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  _ProfileHeaderCard(
                    user: user,
                    className: studentAsync.valueOrNull?.className,
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel(text: 'Data Akademik'),
                  const SizedBox(height: 8),
                  _DataAkademikSection(isActive: user?.isActive ?? false),
                  const SizedBox(height: 20),
                  const _SectionLabel(text: 'Pengaturan Akun'),
                  const SizedBox(height: 8),
                  _PengaturanCard(
                    onNotifikasi: () => context.push('/notifications'),
                  ),
                  const SizedBox(height: 24),
                  _LogoutButton(
                    onTap: () => _confirmLogout(context, ref),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Versi Aplikasi 1.0.0 (Stable)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF747780),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotification});

  final VoidCallback onNotification;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF002B5B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logoAMBIS.png',
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) => const Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'AMBIS',
            style: TextStyle(
              color: Color(0xFF002B5B),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onNotification,
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF002B5B),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Header Card ───────────────────────────────────────────────────────

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.user, required this.className});

  final UserEntity? user;
  final String? className;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.fullname ?? '-';
    final nisn = user?.nisn ?? '-';
    final kelas = className ?? '-';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C6D0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiaryFixedDim,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      color: Color(0xFF001736),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF001736),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'NISN: $nisn',
            style: const TextStyle(
              color: Color(0xFF747780),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF002B5B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF002B5B).withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school_rounded,
                  color: AppColors.secondary,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  kelas,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF001736),
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ── Data Akademik Section ─────────────────────────────────────────────────────

class _DataAkademikSection extends StatelessWidget {
  const _DataAkademikSection({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _AkademikCard(
          label: 'WALI KELAS',
          icon: Icons.person_rounded,
          child: Text(
            'Drs. Budi Santoso, M.Pd.',
            style: TextStyle(
              color: Color(0xFF001736),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(
              child: _AkademikCard(
                label: 'SEMESTER',
                icon: Icons.calendar_today_rounded,
                child: Text(
                  'Ganjil 23/24',
                  style: TextStyle(
                    color: Color(0xFF001736),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AkademikCard(
                label: 'STATUS',
                icon: null,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFF747780),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF059669)
                            : const Color(0xFF747780),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AkademikCard extends StatelessWidget {
  const _AkademikCard({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: const BorderSide(color: AppColors.secondary, width: 4),
          top: BorderSide(color: const Color(0xFFC4C6D0).withValues(alpha: 0.6)),
          right:
              BorderSide(color: const Color(0xFFC4C6D0).withValues(alpha: 0.6)),
          bottom:
              BorderSide(color: const Color(0xFFC4C6D0).withValues(alpha: 0.6)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF747780),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          if (icon != null) ...[
            Row(
              children: [
                Icon(icon, color: AppColors.secondary, size: 18),
                const SizedBox(width: 6),
                Expanded(child: child),
              ],
            ),
          ] else
            child,
        ],
      ),
    );
  }
}

// ── Pengaturan Akun Card ──────────────────────────────────────────────────────

class _PengaturanCard extends StatelessWidget {
  const _PengaturanCard({required this.onNotifikasi});

  final VoidCallback onNotifikasi;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.lock_reset_rounded,
            label: 'Ubah PIN / Password',
            onTap: () {},
            isFirst: true,
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.notifications_active_rounded,
            label: 'Pengaturan Notifikasi',
            onTap: onNotifikasi,
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.support_agent_rounded,
            label: 'Bantuan & Layanan IT',
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0x1AC4C6D0),
      indent: 56,
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF001736).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF001736), size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF191C1E),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF747780),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Keluar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
