import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambis_attendance/core/database/app_database.dart';
import 'package:ambis_attendance/features/grades/data/repositories/grade_repository.dart';

void main() {
  late AppDatabase db;
  late GradeRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = GradeRepository(db);
  });

  tearDown(() async => db.close());

  test('seedIfEmpty inserts 60 rows (10 subjects × 2 semesters × 3 types) when empty', () async {
    await repo.seedIfEmpty('student1');
    final rows = await db.select(db.grades).get();
    expect(rows.length, 60);
  });

  test('seedIfEmpty is idempotent — calling twice keeps same count', () async {
    await repo.seedIfEmpty('student1');
    await repo.seedIfEmpty('student1');
    final rows = await db.select(db.grades).get();
    expect(rows.length, 60);
  });

  test('getGradesByStudent returns 10 subjects for semester 1', () async {
    await repo.seedIfEmpty('student1');
    final (grades, _) = await repo.getGradesByStudent('student1', 1);
    expect(grades.length, 10);
  });

  test('getGradesByStudent — Matematika sem 1 scores are correct', () async {
    await repo.seedIfEmpty('student1');
    final (grades, _) = await repo.getGradesByStudent('student1', 1);
    final mtk = grades.firstWhere((g) => g.subject == 'Matematika');
    expect(mtk.utsScore, 78.0);
    expect(mtk.uasScore, 82.0);
    expect(mtk.tugasScore, 85.0);
    expect(mtk.average, closeTo(81.67, 0.01));
  });

  test('GradeSummary predikat is B+ for avg ~83.6 (sem 1)', () async {
    await repo.seedIfEmpty('student1');
    final (_, summary) = await repo.getGradesByStudent('student1', 1);
    expect(summary.predikat, 'B+');
    expect(summary.overallAverage, greaterThan(83.0));
  });

  test('getGradesByStudent returns empty list when no data', () async {
    final (grades, summary) = await repo.getGradesByStudent('unknown', 1);
    expect(grades, isEmpty);
    expect(summary.predikat, '-');
  });
}
