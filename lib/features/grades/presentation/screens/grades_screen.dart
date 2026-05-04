import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../data/repositories/grade_repository.dart';
import '../providers/grades_provider.dart';

class GradesScreen extends ConsumerWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nilai Akademik'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Semester 1'), Tab(text: 'Semester 2')],
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorWeight: 3,
          ),
        ),
        body: const GradientBackground(
          child: TabBarView(
            children: [
              _GradesTab(semester: 1),
              _GradesTab(semester: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradesTab extends ConsumerWidget {
  const _GradesTab({required this.semester});

  final int semester;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gradesProvider(semester));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Gagal memuat nilai: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: Spacing.sm),
              ElevatedButton(
                onPressed: () => ref.invalidate(gradesProvider(semester)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      data: (result) {
        final (grades, summary) = result;
        if (grades.isEmpty) {
          return const Center(
            child: Text(
              'Nilai belum tersedia.',
              style: TextStyle(color: AppColors.textHint),
            ),
          );
        }
        return _GradesListView(grades: grades, summary: summary);
      },
    );
  }
}

class _GradesListView extends StatelessWidget {
  const _GradesListView({required this.grades, required this.summary});

  final List<SubjectGrade> grades;
  final GradeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryCard(summary: summary),
        _GradesChart(grades: grades),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md, Spacing.sm, Spacing.md, Spacing.lg,
            ),
            itemCount: grades.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.xs),
            itemBuilder: (_, i) => _SubjectGradeCard(grade: grades[i]),
          ),
        ),
      ],
    );
  }
}

class _GradesChart extends StatelessWidget {
  const _GradesChart({required this.grades});

  final List<SubjectGrade> grades;

  String _abbr(String subject) {
    const map = {
      'Matematika': 'MTK',
      'Bahasa Indonesia': 'B.IND',
      'Bahasa Inggris': 'B.ING',
      'Fisika': 'FIS',
      'Kimia': 'KIM',
      'Biologi': 'BIO',
      'Sejarah Indonesia': 'SEJ',
      'Pendidikan Pancasila': 'PKN',
      'Pendidikan Agama Islam': 'PAI',
      'Pendidikan Jasmani': 'PJOK',
    };
    return map[subject] ?? subject.substring(0, 3).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
      padding: const EdgeInsets.fromLTRB(Spacing.sm, Spacing.md, Spacing.sm, Spacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: Spacing.xs, bottom: Spacing.xs),
            child: Text(
              'Rata-rata per Mapel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: 50,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.surfaceAlt,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: 28,
                      getTitlesWidget: (val, _) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= grades.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _abbr(grades[idx].subject),
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 8,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < grades.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: grades[i].average,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    ),
                ],
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.surfaceAlt,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      rod.toY.toStringAsFixed(1),
                      const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final GradeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                _SummaryColumn(
                  label: 'Rata-rata',
                  value: summary.overallAverage.toStringAsFixed(1),
                  valueStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const _VerticalDivider(),
                _SummaryColumn(
                  label: 'Ranking',
                  value: '${summary.rank} dari ${summary.totalStudents}',
                ),
                const _VerticalDivider(),
                _SummaryColumn(
                  label: 'Predikat',
                  value: summary.predikat,
                  valueStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
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

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: valueStyle ??
                Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.surfaceAlt,
      margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
    );
  }
}

class _SubjectGradeCard extends StatelessWidget {
  const _SubjectGradeCard({required this.grade});

  final SubjectGrade grade;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    grade.subject,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  grade.average.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              children: [
                _ScoreBadge(label: 'UTS', score: grade.utsScore),
                const SizedBox(width: Spacing.xs),
                _ScoreBadge(label: 'UAS', score: grade.uasScore),
                const SizedBox(width: Spacing.xs),
                _ScoreBadge(label: 'Tugas', score: grade.tugasScore),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.label, required this.score});

  final String label;
  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            score.toStringAsFixed(0),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
