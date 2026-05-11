import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/data/dummy_notifications.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _todayAttendanceProvider =
    FutureProvider.autoDispose<AttendanceEntity?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  final db = ref.watch(appDatabaseProvider);
  final today = _todayStr();
  return (db.select(db.attendance)
        ..where((a) => a.studentId.equals(user.id))
        ..where((a) => a.date.equals(today)))
      .getSingleOrNull();
});

final _recentAttendanceProvider =
    FutureProvider.autoDispose<List<AttendanceEntity>>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return [];
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.attendance)
        ..where((a) => a.studentId.equals(user.id))
        ..orderBy([(a) => OrderingTerm.desc(a.date)])
        ..limit(5))
      .get();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final todayAtt = ref.watch(_todayAttendanceProvider);
    final recentAtt = ref.watch(_recentAttendanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(nisn: user?.nisn),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  _GreetingSection(
                    name: user?.fullname.split(' ').first ?? 'Siswa',
                  ),
                  const SizedBox(height: 16),
                  _AttendanceStatusCard(attendance: todayAtt),
                  const SizedBox(height: 16),
                  _QuickActionsGrid(
                    onAbsensi: () => context.go('/attendance'),
                    onNilai: () => context.go('/grades'),
                    onIzin: () => context.push('/leave'),
                  ),
                  const SizedBox(height: 24),
                  _RiwayatSection(recent: recentAtt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({this.nisn});
  final String? nisn;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E3E8)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF002B5B),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/LogoAMBIS.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'SMAN 07 Tangerang',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF002B5B),
              ),
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF43474F),
                ),
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
                      color: Color(0xFFBA1A1A),
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
    );
  }
}

// ── Greeting ──────────────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $name!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191C1E),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Semangat belajar hari ini.',
          style: TextStyle(fontSize: 14, color: Color(0xFF43474F)),
        ),
      ],
    );
  }
}

// ── Attendance Status Card ─────────────────────────────────────────────────────

class _AttendanceStatusCard extends StatelessWidget {
  const _AttendanceStatusCard({required this.attendance});
  final AsyncValue<AttendanceEntity?> attendance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6D0).withAlpha(80)),
        // Left accent border
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left teal accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF006A63),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS KEHADIRAN HARI INI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: Color(0xFF43474F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  attendance.when(
                    loading: () => const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Text(
                      'Gagal memuat data',
                      style: TextStyle(fontSize: 13, color: Colors.red),
                    ),
                    data: (att) => _AttendanceInfo(attendance: att),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF47FBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.how_to_reg_rounded,
                color: Color(0xFF006A63),
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceInfo extends StatelessWidget {
  const _AttendanceInfo({required this.attendance});
  final AttendanceEntity? attendance;

  @override
  Widget build(BuildContext context) {
    if (attendance == null) {
      return const Row(
        children: [
          _StatusBadge(label: 'Belum Absen', color: Color(0xFFECEEF0), textColor: Color(0xFF43474F)),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Belum ada absensi hari ini',
              style: TextStyle(fontSize: 12, color: Color(0xFF747780)),
            ),
          ),
        ],
      );
    }
    final (label, color, textColor) = _statusStyle(attendance!.status);
    final timeStr = attendance!.timeIn != null
        ? 'Masuk ${_formatTime(attendance!.timeIn!)} WIB'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusBadge(label: label, color: color, textColor: textColor),
        if (timeStr != null) ...[
          const SizedBox(height: 6),
          Text(
            timeStr,
            style: const TextStyle(fontSize: 13, color: Color(0xFF43474F)),
          ),
        ],
      ],
    );
  }

  (String, Color, Color) _statusStyle(String status) => switch (status) {
        'present' => ('Hadir', const Color(0xFF16A34A), Colors.white),
        'late' => ('Terlambat', const Color(0xFFEA580C), Colors.white),
        'absent' => ('Tidak Hadir', const Color(0xFFBA1A1A), Colors.white),
        'leave' => ('Izin', const Color(0xFF1D4ED8), Colors.white),
        'sick' => ('Sakit', const Color(0xFF7C3AED), Colors.white),
        _ => ('Tidak Diketahui', const Color(0xFFECEEF0), const Color(0xFF43474F)),
      };
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.textColor,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.onAbsensi,
    required this.onNilai,
    required this.onIzin,
  });
  final VoidCallback onAbsensi;
  final VoidCallback onNilai;
  final VoidCallback onIzin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Absensi — primary dark
        Expanded(
          child: _PrimaryActionTile(
            icon: Icons.fingerprint_rounded,
            label: 'Absensi',
            onTap: onAbsensi,
          ),
        ),
        const SizedBox(width: 12),
        // Nilai — outlined
        Expanded(
          child: _SecondaryActionTile(
            icon: Icons.bar_chart_rounded,
            label: 'Nilai',
            onTap: onNilai,
          ),
        ),
        const SizedBox(width: 12),
        // Izin — outlined
        Expanded(
          child: _SecondaryActionTile(
            icon: Icons.description_outlined,
            label: 'Izin & Sakit',
            onTap: onIzin,
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionTile extends StatelessWidget {
  const _PrimaryActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF001736),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF001736).withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionTile extends StatelessWidget {
  const _SecondaryActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC4C6D0).withAlpha(130)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF006A63), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191C1E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Riwayat Absensi ───────────────────────────────────────────────────────────

class _RiwayatSection extends StatelessWidget {
  const _RiwayatSection({required this.recent});
  final AsyncValue<List<AttendanceEntity>> recent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RIWAYAT ABSENSI',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: Color(0xFF43474F),
          ),
        ),
        const SizedBox(height: 10),
        recent.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const Center(
            child: Text(
              'Gagal memuat riwayat.',
              style: TextStyle(fontSize: 13, color: Colors.red),
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFC4C6D0).withAlpha(80),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 40,
                      color: Color(0xFFC4C6D0),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada riwayat absensi.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF747780),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                ...list.map((att) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AttendanceHistoryCard(att: att),
                    )),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context.push('/history'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF006A63),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'LIHAT SEMUA RIWAYAT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  const _AttendanceHistoryCard({required this.att});
  final AttendanceEntity att;

  @override
  Widget build(BuildContext context) {
    final isComplete = att.timeIn != null && att.timeOut != null;
    final badgeLabel = isComplete
        ? 'LENGKAP'
        : att.timeIn != null
            ? 'DATANG SAJA'
            : 'TIDAK HADIR';
    final (badgeBg, badgeFg) = isComplete
        ? (const Color(0xFF47FBEB), const Color(0xFF006A63))
        : att.timeIn != null
            ? (const Color(0xFFFEF9C3), const Color(0xFF854D0E))
            : (const Color(0xFFFFE4E6), const Color(0xFF9F1239));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6D0).withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date row + badge
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(att.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191C1E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE6E8EA)),
          const SizedBox(height: 12),

          // DATANG / PULANG row
          Row(
            children: [
              Expanded(
                child: _TimeBlock(
                  label: 'DATANG',
                  time: att.timeIn != null ? _formatTime(att.timeIn!) : '—',
                  iconBg: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  icon: Icons.login_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE6E8EA),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _TimeBlock(
                  label: 'PULANG',
                  time: att.timeOut != null ? _formatTime(att.timeOut!) : '—',
                  iconBg: const Color(0xFFDBEAFE),
                  iconColor: const Color(0xFF1D4ED8),
                  icon: Icons.logout_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.label,
    required this.time,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });
  final String label;
  final String time;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Color(0xFF43474F),
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF191C1E),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _todayStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _formatTime(String timeStr) {
  // Input: HH:MM:SS or HH:MM → output: HH:MM
  final parts = timeStr.split(':');
  if (parts.length >= 2) {
    return '${parts[0]}:${parts[1]}';
  }
  return timeStr;
}

String _formatDate(String dateStr) {
  const days = [
    '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  const months = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  try {
    final d = DateTime.parse(dateStr);
    return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
  } catch (_) {
    return dateStr;
  }
}
