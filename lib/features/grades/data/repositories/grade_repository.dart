import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Canonical subject list — mirrors the web admin input order.
const kSubjects = [
  'Matematika',
  'Bahasa Indonesia',
  'Bahasa Inggris',
  'Fisika',
  'Kimia',
  'Biologi',
  'Sejarah Indonesia',
  'Pendidikan Pancasila',
  'Pendidikan Agama Islam',
  'Pendidikan Jasmani',
];

class SubjectGrade {
  const SubjectGrade({
    required this.subject,
    this.utsScore,
    this.uasScore,
    this.tugasScore,
  });

  final String subject;
  final double? utsScore;
  final double? uasScore;
  final double? tugasScore;

  bool get hasAnyScore => utsScore != null || uasScore != null;

  /// Complete = both UTS and UAS are present.
  bool get isComplete => utsScore != null && uasScore != null;

  /// null when either UTS or UAS is missing.
  double? get average {
    if (utsScore == null || uasScore == null) return null;
    final vals = <double>[utsScore!, uasScore!];
    if (tugasScore != null) vals.add(tugasScore!);
    return vals.reduce((a, b) => a + b) / vals.length;
  }
}

class GradeSummary {
  const GradeSummary({
    this.overallAverage,
    required this.predikat,
    this.academicYear = '2023/2024',
    this.rank = 5,
    this.totalStudents = 32,
  });

  /// null means data is not yet complete — show "–" in the UI.
  final double? overallAverage;
  final String predikat;
  final String academicYear;
  final int rank;
  final int totalStudents;

  static const GradeSummary empty = GradeSummary(
    overallAverage: null,
    predikat: '–',
  );
}

String _predikatFromAvg(double avg) {
  if (avg >= 90) return 'A';
  if (avg >= 85) return 'B+';
  if (avg >= 80) return 'B';
  if (avg >= 75) return 'C+';
  if (avg >= 70) return 'C';
  return 'D';
}

String _academicYearFromDataYear(int? dataYear) {
  final now = DateTime.now();
  final y = dataYear ?? (now.month >= 7 ? now.year : now.year - 1);
  return '$y/${y + 1}';
}

class GradeRepository {
  /// Fetches grades from Supabase for [studentId] in [semester].
  /// Always returns all [kSubjects]; missing scores are null (displayed as "–").
  /// [GradeSummary.overallAverage] is null until every subject with at least
  /// one score entered has both UTS and UAS.
  Future<(List<SubjectGrade>, GradeSummary)> getGradesFromSupabase(
    String studentId,
    int semester,
  ) async {
    final supabase = sb.Supabase.instance.client;
    final List<dynamic> rows = await supabase
        .from('grades')
        .select('subject, type, score, year')
        .eq('student_id', studentId)
        .eq('semester', semester);

    final bySubject = <String, Map<String, double>>{};
    int? dataYear;
    for (final row in rows) {
      final subject = row['subject'] as String;
      final type = row['type'] as String;
      final score = (row['score'] as num).toDouble();
      dataYear ??= row['year'] as int?;
      bySubject.putIfAbsent(subject, () => {})[type] = score;
    }

    // Always build all predefined subjects, nulls for missing scores.
    final grades = kSubjects.map((subject) {
      final scores = bySubject[subject];
      return SubjectGrade(
        subject: subject,
        utsScore: scores?['UTS'],
        uasScore: scores?['UAS'],
        tugasScore: scores?['tugas'],
      );
    }).toList();

    // Average only when every subject with any score has both UTS & UAS.
    final withData = grades.where((g) => g.hasAnyScore).toList();
    double? overallAvg;
    String predikat = '–';
    if (withData.isNotEmpty && withData.every((g) => g.isComplete)) {
      final avgs = withData.map((g) => g.average!).toList();
      overallAvg = avgs.reduce((a, b) => a + b) / avgs.length;
      predikat = _predikatFromAvg(overallAvg);
    }

    return (
      grades,
      GradeSummary(
        overallAverage: overallAvg,
        predikat: predikat,
        academicYear: _academicYearFromDataYear(dataYear),
      ),
    );
  }
}

final gradeRepositoryProvider = Provider<GradeRepository>((ref) {
  return GradeRepository();
});
