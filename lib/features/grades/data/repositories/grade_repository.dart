import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

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

  /// Averages only scores that were actually provided (non-null).
  double? get average {
    final vals = [utsScore, uasScore, tugasScore].whereType<double>().toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }
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
  /// Returns grouped SubjectGrade list + summary.
  /// Returns an empty list when no rows exist for that student/semester.
  /// Throws on network or Supabase errors so callers can surface them.
  Future<(List<SubjectGrade>, GradeSummary)> getGradesFromSupabase(
    String studentId,
    int semester,
  ) async {
    final supabase = sb.Supabase.instance.client;
    final List<dynamic> rows = await supabase
        .from('grades')
        .select('subject, type, score')
        .eq('student_id', studentId)
        .eq('semester', semester);

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
      final rawTugas = scores['tugas'];
      return SubjectGrade(
        subject: subject,
        utsScore: scores['UTS'],
        uasScore: scores['UAS'],
        tugasScore: rawTugas,
      );
    }).toList();

    final validAvgs = grades.map((g) => g.average).whereType<double>().toList();
    final overallAvg = validAvgs.isEmpty
        ? 0.0
        : validAvgs.reduce((a, b) => a + b) / validAvgs.length;

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
