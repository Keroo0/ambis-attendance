import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';

const Uuid _uuid = Uuid();

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

// Ordered list of subjects for consistent display order.
const _kSubjectOrder = [
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

// Seed data: 10 subjects × 2 semesters × 3 types = 60 rows.
// Identical to dummy_grades.dart values; sem 2 is ~2 pts higher.
const _kSeedData = [
  // semester 1
  ('Matematika',            1, 'UTS', 78.0), ('Matematika',            1, 'UAS', 82.0), ('Matematika',            1, 'tugas', 85.0),
  ('Bahasa Indonesia',      1, 'UTS', 88.0), ('Bahasa Indonesia',      1, 'UAS', 90.0), ('Bahasa Indonesia',      1, 'tugas', 92.0),
  ('Bahasa Inggris',        1, 'UTS', 82.0), ('Bahasa Inggris',        1, 'UAS', 85.0), ('Bahasa Inggris',        1, 'tugas', 88.0),
  ('Fisika',                1, 'UTS', 75.0), ('Fisika',                1, 'UAS', 79.0), ('Fisika',                1, 'tugas', 83.0),
  ('Kimia',                 1, 'UTS', 72.0), ('Kimia',                 1, 'UAS', 76.0), ('Kimia',                 1, 'tugas', 80.0),
  ('Biologi',               1, 'UTS', 80.0), ('Biologi',               1, 'UAS', 83.0), ('Biologi',               1, 'tugas', 87.0),
  ('Sejarah Indonesia',     1, 'UTS', 85.0), ('Sejarah Indonesia',     1, 'UAS', 88.0), ('Sejarah Indonesia',     1, 'tugas', 90.0),
  ('Pendidikan Pancasila',  1, 'UTS', 90.0), ('Pendidikan Pancasila',  1, 'UAS', 92.0), ('Pendidikan Pancasila',  1, 'tugas', 94.0),
  ('Pendidikan Agama Islam',1, 'UTS', 91.0), ('Pendidikan Agama Islam',1, 'UAS', 93.0), ('Pendidikan Agama Islam',1, 'tugas', 95.0),
  ('Pendidikan Jasmani',    1, 'UTS', 88.0), ('Pendidikan Jasmani',    1, 'UAS', 90.0), ('Pendidikan Jasmani',    1, 'tugas', 92.0),
  // semester 2 (~2 pts higher for variation)
  ('Matematika',            2, 'UTS', 80.0), ('Matematika',            2, 'UAS', 84.0), ('Matematika',            2, 'tugas', 87.0),
  ('Bahasa Indonesia',      2, 'UTS', 90.0), ('Bahasa Indonesia',      2, 'UAS', 91.0), ('Bahasa Indonesia',      2, 'tugas', 93.0),
  ('Bahasa Inggris',        2, 'UTS', 84.0), ('Bahasa Inggris',        2, 'UAS', 87.0), ('Bahasa Inggris',        2, 'tugas', 89.0),
  ('Fisika',                2, 'UTS', 77.0), ('Fisika',                2, 'UAS', 81.0), ('Fisika',                2, 'tugas', 85.0),
  ('Kimia',                 2, 'UTS', 74.0), ('Kimia',                 2, 'UAS', 78.0), ('Kimia',                 2, 'tugas', 82.0),
  ('Biologi',               2, 'UTS', 82.0), ('Biologi',               2, 'UAS', 85.0), ('Biologi',               2, 'tugas', 89.0),
  ('Sejarah Indonesia',     2, 'UTS', 87.0), ('Sejarah Indonesia',     2, 'UAS', 90.0), ('Sejarah Indonesia',     2, 'tugas', 92.0),
  ('Pendidikan Pancasila',  2, 'UTS', 92.0), ('Pendidikan Pancasila',  2, 'UAS', 93.0), ('Pendidikan Pancasila',  2, 'tugas', 95.0),
  ('Pendidikan Agama Islam',2, 'UTS', 93.0), ('Pendidikan Agama Islam',2, 'UAS', 94.0), ('Pendidikan Agama Islam',2, 'tugas', 96.0),
  ('Pendidikan Jasmani',    2, 'UTS', 89.0), ('Pendidikan Jasmani',    2, 'UAS', 91.0), ('Pendidikan Jasmani',    2, 'tugas', 93.0),
];

class GradeRepository {
  GradeRepository(this._db);

  final AppDatabase _db;

  /// Inserts 60 seed rows if this student has no grades yet. Idempotent.
  Future<void> seedIfEmpty(String studentId) async {
    final existing = await (_db.select(_db.grades)
          ..where((g) => g.studentId.equals(studentId)))
        .get();
    if (existing.isNotEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final (subject, semester, type, score) in _kSeedData) {
      await _db.into(_db.grades).insert(
        GradesCompanion.insert(
          id: _uuid.v4(),
          studentId: studentId,
          subject: subject,
          type: type,
          score: score,
          semester: drift.Value(semester),
          year: const drift.Value(2025),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  /// Returns grades grouped by subject for [studentId] in [semester] (1 or 2).
  Future<(List<SubjectGrade>, GradeSummary)> getGradesByStudent(
    String studentId,
    int semester,
  ) async {
    final rows = await (_db.select(_db.grades)
          ..where((g) => g.studentId.equals(studentId))
          ..where((g) => g.semester.equals(semester)))
        .get();

    if (rows.isEmpty) return (<SubjectGrade>[], GradeSummary.empty);

    final bySubject = <String, Map<String, double>>{};
    for (final row in rows) {
      bySubject.putIfAbsent(row.subject, () => {})[row.type] = row.score;
    }

    final grades = _kSubjectOrder
        .where(bySubject.containsKey)
        .map((subject) {
          final scores = bySubject[subject]!;
          return SubjectGrade(
            subject: subject,
            utsScore: scores['UTS'] ?? 0,
            uasScore: scores['UAS'] ?? 0,
            tugasScore: scores['tugas'] ?? 0,
          );
        })
        .toList();

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
  return GradeRepository(ref.watch(appDatabaseProvider));
});
