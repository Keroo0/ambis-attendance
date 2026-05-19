import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/grade_repository.dart';
import '../providers/grades_provider.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  int _semester = 1;
  bool _isExporting = false;

  String get _tahunAjaran {
    final now = DateTime.now();
    final y = now.month >= 7 ? now.year : now.year - 1;
    return '$y/${y + 1}';
  }

  Future<void> _exportToExcel(
    List<SubjectGrade> grades,
    GradeSummary summary,
  ) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Laporan Nilai'];
      try {
        excel.delete('Sheet1');
      } catch (_) {}

      sheet.appendRow([
        TextCellValue('Laporan Nilai – Semester $_semester'),
      ]);
      sheet.appendRow([
        TextCellValue('Tahun Ajaran ${summary.academicYear}'),
      ]);
      sheet.appendRow([TextCellValue('')]);
      sheet.appendRow([
        TextCellValue('No'),
        TextCellValue('Mata Pelajaran'),
        TextCellValue('UTS'),
        TextCellValue('UAS'),
      ]);

      for (int i = 0; i < grades.length; i++) {
        final g = grades[i];
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(g.subject),
          g.utsScore != null
              ? DoubleCellValue(g.utsScore!)
              : TextCellValue('–'),
          g.uasScore != null
              ? DoubleCellValue(g.uasScore!)
              : TextCellValue('–'),
        ]);
      }

      sheet.appendRow([TextCellValue('')]);
      final avg = summary.overallAverage;
      sheet.appendRow([
        TextCellValue(''),
        TextCellValue('Rata-rata Semester'),
        TextCellValue(''),
        avg != null ? DoubleCellValue(avg) : TextCellValue('–'),
      ]);

      final bytes = excel.save();
      if (bytes == null) throw Exception('Gagal membuat file Excel');

      final dir = await getTemporaryDirectory();
      final fileName =
          'laporan_nilai_sem${_semester}_${summary.academicYear.replaceAll('/', '-')}.xlsx';
      final file = File(p.join(dir.path, fileName));
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        subject: 'Laporan Nilai Semester $_semester – ${summary.academicYear}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

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
                      'assets/images/LogoAMBIS.png',
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
                    onPressed: () => context.push('/notifications'),
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
                    // Title
                    const Text(
                      'Laporan Nilai',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF001736),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tahun Ajaran $_tahunAjaran',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF43474F),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Summary card (full width)
                    async.when(
                      loading: () =>
                          const _SummaryCard(summary: GradeSummary.empty),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (result) => _SummaryCard(summary: result.$2)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.05, end: 0),
                    ),
                    const SizedBox(height: 16),

                    // Semester toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E3E5)),
                      ),
                      child: Row(
                        children: [
                          _SemesterTab(
                            label: 'Semester 1',
                            selected: _semester == 1,
                            onTap: () => setState(() => _semester = 1),
                          ),
                          _SemesterTab(
                            label: 'Semester 2',
                            selected: _semester == 2,
                            onTap: () => setState(() => _semester = 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grades table
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
                      data: (result) => _GradesTableCard(
                        grades: result.$1,
                        isExporting: _isExporting,
                        onDownload: () =>
                            _exportToExcel(result.$1, result.$2),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 300.ms),
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

// ── Summary card (full width) ─────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final GradeSummary summary;

  @override
  Widget build(BuildContext context) {
    final avg = summary.overallAverage;
    final passed = avg != null && avg >= 75;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RATA-RATA SEMESTER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: Color(0xFF43474F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  avg != null ? avg.toStringAsFixed(1) : '–',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001736),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 52,
            color: const Color(0xFFE0E3E5),
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
              const SizedBox(height: 6),
              if (avg == null)
                const Text(
                  '–',
                  style: TextStyle(fontSize: 16, color: Color(0xFF747780)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
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
                      color: passed ? const Color(0xFF006A63) : Colors.red,
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
  const _GradesTableCard({
    required this.grades,
    required this.isExporting,
    required this.onDownload,
  });

  final List<SubjectGrade> grades;
  final bool isExporting;
  final VoidCallback onDownload;

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E5).withAlpha(200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 4, color: const Color(0xFF006A63)),
          Expanded(
            child: Column(
        children: [
          // Header row
          Container(
            color: const Color(0xFF001736),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: const Row(
              children: [
                Expanded(
                  child: Text('MATA PELAJARAN', style: _headerStyle),
                ),
                SizedBox(
                  width: 44,
                  child: Text('UTS',
                      style: _headerStyle, textAlign: TextAlign.right),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 44,
                  child: Text('UAS',
                      style: _headerStyle, textAlign: TextAlign.right),
                ),
              ],
            ),
          ),

          // Data rows
          ...List.generate(grades.length, (i) {
            final g = grades[i];
            final isAlt = i.isOdd;
            return Container(
              color: isAlt ? const Color(0xFFF7F9FB) : Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
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
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      g.utsScore?.toStringAsFixed(0) ?? '–',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF43474F)),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 44,
                    child: Text(
                      g.uasScore?.toStringAsFixed(0) ?? '–',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF43474F)),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F6),
              border: Border(top: BorderSide(color: Color(0xFFE0E3E5))),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 15, color: Color(0xFF43474F)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Nilai minimum kelulusan: 75',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF43474F)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: isExporting ? null : onDownload,
                  icon: isExporting
                      ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Color(0xFF006A63),
                          ),
                        )
                      : const Icon(Icons.download_outlined, size: 15),
                  label: Text(
                      isExporting ? 'Mengunduh...' : 'Unduh Transkrip'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF006A63),
                    side: const BorderSide(color: Color(0xFF006A63)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
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
}

// ── Error view ─────────────────────────────────────────────────────────────

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
