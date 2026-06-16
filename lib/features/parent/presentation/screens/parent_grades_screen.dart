import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../grades/data/repositories/grade_repository.dart';
import '../providers/parent_provider.dart';
import '../widgets/parent_bottom_nav.dart';

class ParentGradesScreen extends ConsumerStatefulWidget {
  const ParentGradesScreen({super.key});

  @override
  ConsumerState<ParentGradesScreen> createState() => _ParentGradesScreenState();
}

class _ParentGradesScreenState extends ConsumerState<ParentGradesScreen> {
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
      final child = ref.read(childInfoProvider).valueOrNull;
      final excel = Excel.createExcel();
      final sheet = excel['Laporan Nilai'];
      try {
        excel.delete('Sheet1');
      } catch (_) {}

      sheet.appendRow([
        TextCellValue('Laporan Nilai Anak - Semester $_semester'),
      ]);
      sheet.appendRow([
        TextCellValue('Nama: ${child?.fullname ?? '-'}'),
      ]);
      sheet.appendRow([
        TextCellValue('NISN: ${child?.nisn ?? '-'}'),
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
        final grade = grades[i];
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(grade.subject),
          grade.utsScore != null
              ? DoubleCellValue(grade.utsScore!)
              : TextCellValue('-'),
          grade.uasScore != null
              ? DoubleCellValue(grade.uasScore!)
              : TextCellValue('-'),
        ]);
      }

      sheet.appendRow([TextCellValue('')]);
      final avg = summary.overallAverage;
      sheet.appendRow([
        TextCellValue(''),
        TextCellValue('Rata-rata Semester'),
        TextCellValue(''),
        avg != null ? DoubleCellValue(avg) : TextCellValue('-'),
      ]);

      final bytes = excel.save();
      if (bytes == null) throw Exception('Gagal membuat file Excel');

      final dir = await getTemporaryDirectory();
      final fileName =
          'laporan_nilai_anak_sem${_semester}_${summary.academicYear.replaceAll('/', '-')}.xlsx';
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
        subject: 'Laporan Nilai Anak Semester $_semester',
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
    final childAsync = ref.watch(childInfoProvider);
    final gradesAsync = ref.watch(childGradesProvider(_semester));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      bottomNavigationBar: const ParentBottomNav(
        currentRoute: '/parent-grades',
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Nilai Anak',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF002B5B),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE0E3E5)),
        ),
      ),
      body: childAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorView(
          message: 'Gagal memuat data anak.',
          onRetry: () => ref.invalidate(childInfoProvider),
        ),
        data: (child) {
          if (child == null) return const _NoChildGradesState();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChildHeader(
                    childName: child.fullname, className: child.className),
                const SizedBox(height: 16),
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
                gradesAsync.when(
                  loading: () =>
                      const _SummaryCard(summary: GradeSummary.empty),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (result) => _SummaryCard(summary: result.$2)
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideX(begin: -0.05, end: 0),
                ),
                const SizedBox(height: 16),
                _SemesterSwitch(
                  semester: _semester,
                  onChanged: (semester) => setState(() {
                    _semester = semester;
                  }),
                ),
                const SizedBox(height: 16),
                gradesAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => _ErrorView(
                    message: 'Gagal memuat nilai: $e',
                    onRetry: () =>
                        ref.invalidate(childGradesProvider(_semester)),
                  ),
                  data: (result) => _GradesTableCard(
                    grades: result.$1,
                    isExporting: _isExporting,
                    onDownload: () => _exportToExcel(result.$1, result.$2),
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChildHeader extends StatelessWidget {
  const _ChildHeader({required this.childName, required this.className});

  final String childName;
  final String className;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFD6E3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF002B5B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001736),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Kelas $className',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF43474F),
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
                  avg != null ? avg.toStringAsFixed(1) : '-',
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
                  '-',
                  style: TextStyle(fontSize: 16, color: Color(0xFF747780)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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

class _SemesterSwitch extends StatelessWidget {
  const _SemesterSwitch({required this.semester, required this.onChanged});

  final int semester;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            selected: semester == 1,
            onTap: () => onChanged(1),
          ),
          _SemesterTab(
            label: 'Semester 2',
            selected: semester == 2,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

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
            border:
                selected ? Border.all(color: const Color(0xFFE0E3E5)) : null,
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
                  Container(
                    color: const Color(0xFF001736),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text('MATA PELAJARAN', style: _headerStyle),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            'UTS',
                            style: _headerStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        SizedBox(width: 12),
                        SizedBox(
                          width: 44,
                          child: Text(
                            'UAS',
                            style: _headerStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(grades.length, (index) {
                    final grade = grades[index];
                    final isAlt = index.isOdd;
                    return Container(
                      color: isAlt ? const Color(0xFFF7F9FB) : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              grade.subject,
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
                              grade.utsScore?.toStringAsFixed(0) ?? '-',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF43474F),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 44,
                            child: Text(
                              grade.uasScore?.toStringAsFixed(0) ?? '-',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF43474F),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F4F6),
                      border: Border(top: BorderSide(color: Color(0xFFE0E3E5))),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 15,
                          color: Color(0xFF43474F),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Nilai minimum kelulusan: 75',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF43474F),
                            ),
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
                            isExporting ? 'Mengunduh...' : 'Unduh Transkrip',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF006A63),
                            side: const BorderSide(color: Color(0xFF006A63)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
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

class _NoChildGradesState extends StatelessWidget {
  const _NoChildGradesState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Belum ada data anak yang terhubung.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF43474F)),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
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
