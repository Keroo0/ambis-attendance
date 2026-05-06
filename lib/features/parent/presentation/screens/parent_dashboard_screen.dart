import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final name = user?.fullname ?? 'Siswa';
    final nisn = user?.nisn ?? '-';

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
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF747780)),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: _ProfileCard(name: name, nisn: nisn),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AttendanceCard(
                    onTap: () => context.push('/parent-history'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _GradesSummaryCard(),
        ],
      ),
    );
  }
}

// ── Profile Card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.name, required this.nisn});

  final String name;
  final String nisn;

  String get _initials {
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6D0)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
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
                        _initials,
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
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191C1E),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.badge_outlined,
                                  size: 12, color: Color(0xFF43474F)),
                              SizedBox(width: 3),
                              Text(
                                'XI IPA 1',
                                style: TextStyle(
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
                                  'NISN: $nisn',
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF43474F)),
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
  const _AttendanceCard({required this.onTap});

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
                color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KEHADIRAN\nBULAN INI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Color(0xFF43474F),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '98%',
                          style: TextStyle(
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
                        const Text(
                          'Status Hari Ini',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF43474F)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF006A63).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF006A63)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 10, color: Color(0xFF006A63)),
                              SizedBox(width: 3),
                              Text(
                                'Hadir',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF006A63),
                                ),
                              ),
                            ],
                          ),
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

class _GradesSummaryCard extends StatelessWidget {
  const _GradesSummaryCard();

  static const _subjects = [
    _SubjectRow('Matematika Wajib', '90', true),
    _SubjectRow('Bahasa Indonesia', '85', false),
    _SubjectRow('Fisika', '92', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6D0)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
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
                            'Sem. Ganjil 2023/2024',
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
                    const Row(
                      children: [
                        Expanded(child: _StatMiniCard()),
                        SizedBox(width: 8),
                        Expanded(child: _TrendMiniCard()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Subject table
                    Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFECEEF0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            color: const Color(0xFF002B5B),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'MATA PELAJARAN UTAMA',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  'NILAI',
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
                          ..._subjects.asMap().entries.map((e) {
                            final isEven = e.key.isEven;
                            final row = e.value;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              color: isEven
                                  ? Colors.white
                                  : const Color(0xFFF7F9FB),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      row.subject,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF191C1E),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    row.score,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: row.isHighlight
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: row.isHighlight
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
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download_outlined, size: 15),
                          label: const Text('Unduh Raport'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF006A63),
                            side: const BorderSide(color: Color(0xFF47FBEB)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.visibility_outlined, size: 15),
                          label: const Text('Laporan Lengkap'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002B5B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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

class _SubjectRow {
  const _SubjectRow(this.subject, this.score, this.isHighlight);
  final String subject;
  final String score;
  final bool isHighlight;
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard();

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RATA-RATA KELAS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Color(0xFF43474F),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '87.5',
                  style: TextStyle(
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

class _TrendMiniCard extends StatelessWidget {
  const _TrendMiniCard();

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TREN PENCAPAIAN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Color(0xFF43474F),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.trending_up_rounded,
                        size: 14, color: Color(0xFF006A63)),
                    SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        'Naik 2.5 poin\ndari UAS lalu',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF006A63),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
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
            child: const Icon(Icons.insights_outlined,
                size: 18, color: Color(0xFF006A63)),
          ),
        ],
      ),
    );
  }
}
