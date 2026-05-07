import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SubjectGrade {
  const SubjectGrade({
    required this.subject,
    required this.utsScore,
    required this.uasScore,
    required this.tugasScore,
  });

  final String subject;
  final double utsScore;
  final double uasScore;
  final double tugasScore;

  double get average => (utsScore + uasScore + tugasScore) / 3;
}

class GradeSummary {
  const GradeSummary({
    required this.overallAverage,
    required this.predikat,
    this.rank = 5,
    this.totalStudents = 32,
  });

  final double overallAverage;
  final String predikat;
  final int rank;
  final int totalStudents;

  static const GradeSummary empty = GradeSummary(
    overallAverage: 0,
    predikat: '-',
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

class GradeRepository {
  /// Fetches grades from Supabase for [studentId] in [semester] (1 or 2).
  /// Returns grouped SubjectGrade list + summary. Empty if no data exists yet.
  Future<(List<SubjectGrade>, GradeSummary)> getGradesFromSupabase(
    String studentId,
    int semester,
  ) async {
    final supabase = sb.Supabase.instance.client;
    final List<dynamic> rows;
    try {
      rows = await supabase
          .from('grades')
          .select('subject, type, score')
          .eq('student_id', studentId)
          .eq('semester', semester);
    } catch (_) {
      return (<SubjectGrade>[], GradeSummary.empty);
    }

    if (rows.isEmpty) return (<SubjectGrade>[], GradeSummary.empty);

    final bySubject = <String, Map<String, double>>{};
    for (final row in rows) {
      final subject = row['subject'] as String;
      final type = row['type'] as String;
      final score = (row['score'] as num).toDouble();
      bySubject.putIfAbsent(subject, () => {})[type] = score;
    }

    final orderedSubjects = bySubject.keys.toList()..sort();
    final grades = orderedSubjects.map((subject) {
      final scores = bySubject[subject]!;
      return SubjectGrade(
        subject: subject,
        utsScore: scores['UTS'] ?? 0,
        uasScore: scores['UAS'] ?? 0,
        tugasScore: scores['tugas'] ?? 0,
      );
    }).toList();

    final overallAvg =
        grades.map((g) => g.average).reduce((a, b) => a + b) / grades.length;

    return (
      grades,
      GradeSummary(
        overallAverage: overallAvg,
        predikat: _predikatFromAvg(overallAvg),
      ),
    );
  }
}

final gradeRepositoryProvider = Provider<GradeRepository>((ref) {
  return GradeRepository();
});
