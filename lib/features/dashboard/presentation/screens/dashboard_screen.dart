import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../enrollment/data/repositories/face_repository.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _hasFaceDataProvider = FutureProvider.autoDispose<bool>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return true;
  return ref.read(faceRepositoryProvider).hasActiveEmbedding(user.id);
});

final _todayAttendanceProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  final today = _todayStr();
  final rows = await Supabase.instance.client
      .from('attendance')
      .select()
      .eq('student_id', user.id)
      .eq('date', today)
      .limit(1);
  final list = rows as List;
  return list.isEmpty ? null : list.first as Map<String, dynamic>;
});

final _recentAttendanceProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return [];
  final rows = await Supabase.instance.client
      .from('attendance')
      .select()
      .eq('student_id', user.id)
      .order('date', ascending: false)
      .limit(5);
  return (rows as List).cast<Map<String, dynamic>>();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(notificationServiceProvider).requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final todayAtt = ref.watch(_todayAttendanceProvider);
    final recentAtt = ref.watch(_recentAttendanceProvider);
    final hasFace = ref.watch(_hasFaceDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEAF4FF),
                Color(0xFFF7F9FB),
                Color(0xFFFFFFFF),
              ],
              stops: [0, 0.46, 1],
            ),
          ),
          child: Column(
            children: [
              _TopBar(nisn: user?.nisn),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  children: [
                    _GreetingSection(
                      name: user?.fullname.split(' ').first ?? 'Siswa',
                    ).animate().fadeIn(delay: 50.ms, duration: 300.ms),
                    if (hasFace.valueOrNull == false) ...[
                      const SizedBox(height: 12),
                      const _FaceWarningBanner()
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 300.ms)
                          .slideY(begin: 0.08, end: 0, duration: 350.ms),
                    ],
                    const SizedBox(height: 12),
                    _AttendanceStatusCard(attendance: todayAtt)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 300.ms)
                        .slideY(begin: 0.08, end: 0, duration: 350.ms),
                    const SizedBox(height: 14),
                    _QuickActionsGrid(
                      onAbsensi: () => context.go('/attendance'),
                      onNilai: () => context.go('/grades'),
                      onIzin: () => context.push('/leave'),
                    )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 300.ms)
                        .slideY(begin: 0.08, end: 0, duration: 350.ms),
                    const SizedBox(height: 22),
                    _RiwayatSection(recent: recentAtt)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 300.ms)
                        .slideY(begin: 0.08, end: 0, duration: 350.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerStatefulWidget {
  const _TopBar({this.nisn});
  final String? nisn;

  @override
  ConsumerState<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<_TopBar> {
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _subscribe());
  }

  void _subscribe() {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;
    _channel = Supabase.instance.client
        .channel('notifications:${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (_) {
            if (mounted) ref.invalidate(notificationsProvider);
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    final ch = _channel;
    if (ch != null) {
      Supabase.instance.client.removeChannel(ch);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(notificationsProvider).maybeWhen(
          data: (list) => list.where((n) => !n.isRead).length,
          orElse: () => 0,
        );
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
              if (unread > 0)
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
                        '$unread',
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
    return Container(
      height: 148,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF002B5B),
            Color(0xFF006A63),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002B5B).withAlpha(45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -38,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(28),
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: -24,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFDF9E).withAlpha(80),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(34),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withAlpha(42)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFDF9E),
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Portal Siswa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Halo, $name!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Semangat belajar hari ini. Cek absensi, nilai, dan izinmu di sini.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.white.withAlpha(220),
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

// ── Face Warning Banner ───────────────────────────────────────────────────────

class _FaceWarningBanner extends StatelessWidget {
  const _FaceWarningBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/enrollment'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFB923C).withAlpha(120)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFED7AA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.face_retouching_off_rounded,
                color: Color(0xFFEA580C),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data wajah belum terdaftar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Daftarkan wajah agar bisa absen',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFEA580C),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Attendance Status Card ─────────────────────────────────────────────────────

class _AttendanceStatusCard extends StatelessWidget {
  const _AttendanceStatusCard({required this.attendance});
  final AsyncValue<Map<String, dynamic>?> attendance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFE8E3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006A63).withAlpha(18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left teal accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF00DECF), Color(0xFF006A63)],
                ),
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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF47FBEB), Color(0xFFFFDF9E)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00DECF).withAlpha(55),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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
  final Map<String, dynamic>? attendance;

  @override
  Widget build(BuildContext context) {
    if (attendance == null) {
      return const Row(
        children: [
          _StatusBadge(
              label: 'Belum Absen',
              color: Color(0xFFECEEF0),
              textColor: Color(0xFF43474F)),
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
    final status = attendance!['status'] as String? ?? '';
    final timeIn = attendance!['time_in'] as String?;
    final (label, color, textColor) = _statusStyle(status);
    final timeStr = timeIn != null ? 'Masuk ${_formatTime(timeIn)} WIB' : null;

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
        _ => (
            'Tidak Diketahui',
            const Color(0xFFECEEF0),
            const Color(0xFF43474F)
          ),
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
          child: _ActionTile(
            icon: Icons.fingerprint_rounded,
            label: 'Absensi',
            onTap: onAbsensi,
            backgroundColor: const Color(0xFF001736),
            iconColor: Colors.white,
            textColor: Colors.white,
            glowColor: const Color(0xFF001736),
          ),
        ),
        const SizedBox(width: 12),
        // Nilai — outlined
        Expanded(
          child: _ActionTile(
            icon: Icons.bar_chart_rounded,
            label: 'Nilai',
            onTap: onNilai,
            backgroundColor: const Color(0xFFEAF4FF),
            iconColor: const Color(0xFF1D4ED8),
            textColor: const Color(0xFF12305F),
            borderColor: const Color(0xFFBFDBFE),
          ),
        ),
        const SizedBox(width: 12),
        // Izin — outlined
        Expanded(
          child: _ActionTile(
            icon: Icons.description_outlined,
            label: 'Izin & Sakit',
            onTap: onIzin,
            backgroundColor: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFEA580C),
            textColor: const Color(0xFF5B4300),
            borderColor: const Color(0xFFFFDF9E),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    this.borderColor,
    this.glowColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color? borderColor;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? backgroundColor.withAlpha(180),
          ),
          boxShadow: glowColor == null
              ? null
              : [
                  BoxShadow(
                    color: glowColor!.withAlpha(52),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
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
  final AsyncValue<List<Map<String, dynamic>>> recent;

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
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 40,
                      color: Color(0xFF1D4ED8),
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
  final Map<String, dynamic> att;

  @override
  Widget build(BuildContext context) {
    final timeIn = att['time_in'] as String?;
    final timeOut = att['time_out'] as String?;
    final date = att['date'] as String? ?? '';

    final isComplete = timeIn != null && timeOut != null;
    final badgeLabel = isComplete
        ? 'LENGKAP'
        : timeIn != null
            ? 'DATANG SAJA'
            : 'TIDAK HADIR';
    final (badgeBg, badgeFg) = isComplete
        ? (const Color(0xFF47FBEB), const Color(0xFF006A63))
        : timeIn != null
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
                  _formatDate(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191C1E),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                  time: timeIn != null ? _formatTime(timeIn) : '—',
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
                  time: timeOut != null ? _formatTime(timeOut) : '—',
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
    '',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  const months = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  try {
    final d = DateTime.parse(dateStr);
    return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
  } catch (_) {
    return dateStr;
  }
}
