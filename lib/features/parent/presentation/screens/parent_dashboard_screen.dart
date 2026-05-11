import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/parent_repository.dart';
import '../providers/parent_provider.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(childInfoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Icon(Icons.school_rounded, color: Color(0xFF002B5B), size: 24),
              SizedBox(width: 10),
              Text(
                'SMAN 07 Kab. Tangerang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF002B5B),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF747780)),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: childAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Color(0xFFC4C6D0)),
              const SizedBox(height: 12),
              const Text('Gagal memuat data anak.',
                  style: TextStyle(color: Color(0xFF43474F))),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(childInfoProvider),
                child: const Text('Coba Lagi',
                    style: TextStyle(color: Color(0xFF006A63))),
              ),
            ],
          ),
        ),
        data: (child) {
          if (child == null) return const _NoChildState();
          final attendanceCountAsync =
              ref.watch(childAttendanceThisMonthProvider);
          final attendanceStr = attendanceCountAsync.when(
            data: (c) => '$c',
            loading: () => '…',
            error: (_, __) => '-',
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _ProfileCard(child: child),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _AttendanceCard(
                        countStr: attendanceStr,
                        onTap: () => context.push('/parent-history'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _GradesSummaryCard(child: child),
            ],
          );
        },
      ),
    );
  }
}

// ── Profile Card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});
  final ChildStudentInfo child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6D0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: const Color(0xFF002B5B)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFD6E3FF),
                      child: Text(
                        child.initials,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF002B5B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            child.fullname,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191C1E),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined,
                                  size: 12, color: Color(0xFF43474F)),
                              const SizedBox(width: 3),
                              Text(
                                child.className,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF43474F)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.pin_outlined,
                                  size: 12, color: Color(0xFF43474F)),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  'NISN: ${child.nisn}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF43474F)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Attendance Card ───────────────────────────────────────────────────────────

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.countStr, required this.onTap});
  final String countStr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC4C6D0)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x05000000),
                blurRadius: 4,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: const Color(0xFF006A63)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KEHADIRAN\nBULAN INI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Color(0xFF43474F),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          countStr,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191C1E),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, color: Color(0xFFECEEF0)),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 10, color: Color(0xFF006A63)),
                            SizedBox(width: 3),
                            Text(
                              'Lihat Riwayat',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF006A63),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grades Summary Card ───────────────────────────────────────────────────────

class _GradesSummaryCard extends ConsumerWidget {
  const _GradesSummaryCard({required this.child});
  final ChildStudentInfo child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradesAsync = ref.watch(childGradesSummaryProvider);
    final avgAsync = ref.watch(childOverallAverageProvider);
    final attendanceAsync = ref.watch(childAttendanceThisMonthProvider);
    final attendanceStr = attendanceAsync.when(
      data: (c) => '$c',
      loading: () => '…',
      error: (_, __) => '-',
    );

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6D0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: const Color(0xFF47FBEB)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Ringkasan Nilai UTS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191C1E),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEEF0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Terbaru',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF43474F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _AvgMiniCard(avgAsync: avgAsync)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _AttendanceMiniCard(
                                countStr: attendanceStr)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    gradesAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Gagal memuat nilai.',
                            style: TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ),
                      data: (grades) => grades.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Nilai belum diinput oleh admin.',
                                  style: TextStyle(
                                      color: Color(0xFF747780),
                                      fontSize: 13),
                                ),
                              ),
                            )
                          : _GradeTable(grades: grades),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvgMiniCard extends StatelessWidget {
  const _AvgMiniCard({required this.avgAsync});
  final AsyncValue<double?> avgAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RATA-RATA',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Color(0xFF43474F),
                  ),
                ),
                const SizedBox(height: 4),
                avgAsync.when(
                  loading: () => const SizedBox(
                    height: 22,
                    child: LinearProgressIndicator(
                      color: Color(0xFF002B5B),
                      backgroundColor: Color(0xFFE0E3E5),
                    ),
                  ),
                  error: (_, __) => const Text('-',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF002B5B))),
                  data: (avg) => Text(
                    avg != null ? avg.toStringAsFixed(1) : '-',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF002B5B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFD6E3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_outlined,
                size: 18, color: Color(0xFF002B5B)),
          ),
        ],
      ),
    );
  }
}

class _AttendanceMiniCard extends StatelessWidget {
  const _AttendanceMiniCard({required this.countStr});
  final String countStr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HADIR\nBULAN INI',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Color(0xFF43474F),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  countStr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF002B5B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF006A63).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fact_check_outlined,
                size: 18, color: Color(0xFF006A63)),
          ),
        ],
      ),
    );
  }
}

class _GradeTable extends StatelessWidget {
  const _GradeTable({required this.grades});
  final List<ChildGradeRow> grades;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFECEEF0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF002B5B),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'MATA PELAJARAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'NILAI UTS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ...grades.asMap().entries.map((e) {
            final isEven = e.key.isEven;
            final row = e.value;
            final isHigh = row.utsScore >= 88;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: isEven ? Colors.white : const Color(0xFFF7F9FB),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.subject,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF191C1E)),
                    ),
                  ),
                  Text(
                    row.utsScore.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isHigh ? FontWeight.w700 : FontWeight.w400,
                      color: isHigh
                          ? const Color(0xFF006A63)
                          : const Color(0xFF191C1E),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── No child linked ───────────────────────────────────────────────────────────

class _NoChildState extends StatelessWidget {
  const _NoChildState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded,
                size: 64, color: Color(0xFFC4C6D0)),
            SizedBox(height: 12),
            Text(
              'Data anak belum terhubung.',
              style: TextStyle(
                  color: Color(0xFF43474F),
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Hubungi admin sekolah untuk menghubungkan akun orang tua.',
              style: TextStyle(color: Color(0xFF747780), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
