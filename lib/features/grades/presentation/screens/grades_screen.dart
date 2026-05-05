import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/grade_repository.dart';
import '../providers/grades_provider.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  int _semester = 1;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gradesProvider(_semester));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Container(
              height: 64,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logoAMBIS.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
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

            // ── Scrollable content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: title + summary bento
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Laporan Nilai',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF001736),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tahun Ajaran 2023/2024',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF43474F)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        async.when(
                          loading: () => const SizedBox(
                            width: 120,
                            child: LinearProgressIndicator(
                              color: Color(0xFF006A63),
                              backgroundColor: Color(0xFFECEEF0),
                            ),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (result) =>
                              _SummaryBento(summary: result.$2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Semester toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: const Color(0xFFE0E3E5)),
                      ),
                      child: Row(
                        children: [
                          _SemesterTab(
                            label: 'Semester 1',
                            selected: _semester == 1,
                            onTap: () =>
                                setState(() => _semester = 1),
                          ),
                          _SemesterTab(
                            label: 'Semester 2',
                            selected: _semester == 2,
                            onTap: () =>
                                setState(() => _semester = 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grades content
                    async.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => _ErrorView(
                        message: 'Gagal memuat nilai: $e',
                        onRetry: () =>
                            ref.invalidate(gradesProvider(_semester)),
                      ),
                      data: (result) {
                        final (grades, _) = result;
                        if (grades.isEmpty) {
                          return const _EmptyView();
                        }
                        return _GradesTableCard(grades: grades);
                      },
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

// ── Summary bento box ──────────────────────────────────────────────────────

class _SummaryBento extends StatelessWidget {
  const _SummaryBento({required this.summary});

  final GradeSummary summary;

  @override
  Widget build(BuildContext context) {
    final passed = summary.overallAverage >= 75;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RATA-RATA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Color(0xFF43474F),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                summary.overallAverage.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF001736),
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE0E3E5),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'STATUS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Color(0xFF43474F),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xFF006A63).withAlpha(20)
                      : Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: passed
                        ? const Color(0xFF006A63).withAlpha(60)
                        : Colors.red.withAlpha(60),
                  ),
                ),
                child: Text(
                  passed ? 'Lulus' : 'Tidak Lulus',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: passed
                        ? const Color(0xFF006A63)
                        : Colors.red,
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

// ── Semester tab button ────────────────────────────────────────────────────

class _SemesterTab extends StatelessWidget {
  const _SemesterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: selected
                ? Border.all(color: const Color(0xFFE0E3E5))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: selected
                    ? const Color(0xFF001736)
                    : const Color(0xFF43474F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Grades table card ──────────────────────────────────────────────────────

class _GradesTableCard extends StatelessWidget {
  const _GradesTableCard({required this.grades});

  final List<SubjectGrade> grades;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: const BorderSide(color: Color(0xFF006A63), width: 4),
          top: BorderSide(
              color: const Color(0xFFE0E3E5).withAlpha(200)),
          right: BorderSide(
              color: const Color(0xFFE0E3E5).withAlpha(200)),
          bottom: BorderSide(
              color: const Color(0xFFE0E3E5).withAlpha(200)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Scrollable table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 44,
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    color: const Color(0xFF001736),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text('MATA PELAJARAN',
                              style: _headerStyle),
                        ),
                        SizedBox(
                            width: 44,
                            child: Text('UTS',
                                style: _headerStyle,
                                textAlign: TextAlign.right)),
                        SizedBox(width: 8),
                        SizedBox(
                            width: 44,
                            child: Text('UAS',
                                style: _headerStyle,
                                textAlign: TextAlign.right)),
                        SizedBox(width: 8),
                        SizedBox(
                            width: 52,
                            child: Text('AKHIR',
                                style: _headerStyle,
                                textAlign: TextAlign.right)),
                        SizedBox(width: 8),
                        SizedBox(
                            width: 76,
                            child: Text('STATUS',
                                style: _headerStyle,
                                textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  // Data rows
                  ...List.generate(grades.length, (i) {
                    final g = grades[i];
                    final avg = g.average;
                    final passed = avg >= 75;
                    final isAlt = i.isOdd;
                    final finalColor = !passed
                        ? Colors.red
                        : avg >= 88
                            ? const Color(0xFF006A63)
                            : const Color(0xFF001736);

                    return Container(
                      color: isAlt
                          ? const Color(0xFFF7F9FB)
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              g.subject,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF001736),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              g.utsScore.toStringAsFixed(0),
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF43474F)),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 44,
                            child: Text(
                              g.uasScore.toStringAsFixed(0),
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF43474F)),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 52,
                            child: Text(
                              avg.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: finalColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 76,
                            child: Center(
                              child: _StatusPill(passed: passed),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F6),
              border: Border(
                  top: BorderSide(color: Color(0xFFE0E3E5))),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 15, color: Color(0xFF43474F)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Nilai minimum kelulusan: 75',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF43474F)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined,
                      size: 15),
                  label: const Text('Unduh Transkrip'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF006A63),
                    side: const BorderSide(
                        color: Color(0xFF006A63)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: Colors.white,
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.passed});

  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: passed
            ? const Color(0xFF006A63).withAlpha(20)
            : Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: passed
              ? const Color(0xFF006A63).withAlpha(60)
              : Colors.red.withAlpha(60),
        ),
      ),
      child: Text(
        passed ? 'Lulus' : 'Remedial',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: passed ? const Color(0xFF006A63) : Colors.red,
        ),
      ),
    );
  }
}

// ── State widgets ──────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006A63),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Text(
          'Nilai belum tersedia.',
          style: TextStyle(color: Color(0xFF747780), fontSize: 14),
        ),
      ),
    );
  }
}
