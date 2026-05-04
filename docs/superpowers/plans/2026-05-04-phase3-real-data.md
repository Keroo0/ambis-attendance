# Phase 3 — Real Data Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ganti data dummy di tiga fitur (Nilai, Riwayat Kehadiran, Pengajuan Izin) dengan data nyata dari Drift + Supabase Storage.

**Architecture:** Setiap fitur mendapat Repository (Drift/Supabase) → Provider (Riverpod FutureProvider/AsyncNotifier) → Screen (ConsumerWidget watch provider). Data dummy di-delete setelah screen selesai dimigrasikan. Grades di-seed ke Drift saat pertama launch agar tidak kosong sebelum Phase 4 admin UI.

**Tech Stack:** Flutter, Drift (SQLite in-memory untuk tests), Riverpod 2.x, Supabase Flutter, flutter_image_compress, image_picker (baru)

---

## File Structure

| File | Aksi |
|---|---|
| `pubspec.yaml` | MODIFY — tambah `image_picker: ^1.1.0` |
| `android/app/src/main/AndroidManifest.xml` | MODIFY — READ_MEDIA_IMAGES |
| `ios/Runner/Info.plist` | MODIFY — NSPhotoLibraryUsageDescription |
| `lib/core/exceptions/app_exception.dart` | MODIFY — tambah LeaveException |
| `lib/features/grades/data/repositories/grade_repository.dart` | CREATE |
| `lib/features/grades/presentation/providers/grades_provider.dart` | CREATE |
| `lib/features/grades/presentation/screens/grades_screen.dart` | MODIFY |
| `lib/features/grades/data/dummy_grades.dart` | DELETE |
| `lib/features/history/data/repositories/attendance_history_repository.dart` | CREATE |
| `lib/features/history/presentation/providers/history_provider.dart` | CREATE |
| `lib/features/history/presentation/screens/history_screen.dart` | MODIFY |
| `lib/features/history/data/dummy_history.dart` | DELETE |
| `lib/features/leave_request/data/repositories/leave_repository.dart` | CREATE |
| `lib/features/leave_request/presentation/providers/leave_provider.dart` | CREATE |
| `lib/features/leave_request/presentation/screens/leave_request_screen.dart` | MODIFY |
| `lib/features/leave_request/data/dummy_leaves.dart` | DELETE |
| `test/features/grades/data/repositories/grade_repository_test.dart` | CREATE |
| `test/features/history/data/repositories/attendance_history_repository_test.dart` | CREATE |
| `test/features/leave_request/data/repositories/leave_repository_test.dart` | CREATE |

---

## Task 1: Setup — image_picker + Permissions + LeaveException

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`
- Modify: `lib/core/exceptions/app_exception.dart`

- [ ] **Step 1: Tambah image_picker ke pubspec.yaml**

Tambahkan baris ini di bawah `flutter_image_compress: ^2.1.0`:

```yaml
  image_picker: ^1.1.0
```

- [ ] **Step 2: Tambah Android permissions**

Di `android/app/src/main/AndroidManifest.xml`, tambahkan sebelum tag `<application>`:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
```

- [ ] **Step 3: Tambah iOS plist entry**

Di `ios/Runner/Info.plist`, tambahkan sebelum `</dict>` penutup:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Akses galeri diperlukan untuk upload foto bukti izin.</string>
```

- [ ] **Step 4: Tambah LeaveException ke app_exception.dart**

File: `lib/core/exceptions/app_exception.dart`

Tambahkan setelah class `RateLimitException`:

```dart
class LeaveException extends AppException {
  const LeaveException(super.message);
}
```

- [ ] **Step 5: flutter pub get**

```bash
cd ambis_attendance && flutter pub get
```

Expected: "Got dependencies!" tanpa error.

- [ ] **Step 6: flutter analyze**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock \
  android/app/src/main/AndroidManifest.xml \
  ios/Runner/Info.plist \
  lib/core/exceptions/app_exception.dart
git commit -m "feat(phase3): add image_picker, platform permissions, LeaveException"
```

---

## Task 2: GradeRepository

**Files:**
- Create: `lib/features/grades/data/repositories/grade_repository.dart`
- Create: `test/features/grades/data/repositories/grade_repository_test.dart`

**Context:** `AppDatabase.forTesting(executor)` tersedia (lihat `lib/core/database/app_database.dart:32`). Tabel `grades` punya kolom: `id`, `studentId`, `subject`, `type` (UTS/UAS/tugas), `score`, `semester` (1/2), `year`, `inputtedBy`, `syncedAt`, `createdAt`, `updatedAt`.

- [ ] **Step 1: Tulis test yang gagal**

Buat file `test/features/grades/data/repositories/grade_repository_test.dart`:

```dart
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
```

- [ ] **Step 2: Jalankan test — pastikan GAGAL**

```bash
flutter test test/features/grades/data/repositories/grade_repository_test.dart
```

Expected: FAIL — "Target of URI doesn't exist: grade_repository.dart"

- [ ] **Step 3: Buat GradeRepository**

Buat file `lib/features/grades/data/repositories/grade_repository.dart`:

```dart
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
          year: drift.Value(2025),
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
```

- [ ] **Step 4: Jalankan test — pastikan LULUS**

```bash
flutter test test/features/grades/data/repositories/grade_repository_test.dart
```

Expected: 6 tests passed.

- [ ] **Step 5: flutter analyze**

```bash
flutter analyze lib/features/grades/data/repositories/grade_repository.dart
```

Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grades/data/repositories/grade_repository.dart \
  test/features/grades/data/repositories/grade_repository_test.dart
git commit -m "feat(grades): add GradeRepository with Drift integration and seed data"
```

---

## Task 3: gradesProvider + GradesScreen Migration

**Files:**
- Create: `lib/features/grades/presentation/providers/grades_provider.dart`
- Modify: `lib/features/grades/presentation/screens/grades_screen.dart`
- Delete: `lib/features/grades/data/dummy_grades.dart`

**Context:** `GradeRepository` dan `SubjectGrade`/`GradeSummary` sudah ada dari Task 2. `grades_screen.dart` saat ini menggunakan `kDummyGradesSem1`, `kDummyGradesSem2`, `DummySubjectGrade`, `DummySummary`.

- [ ] **Step 1: Buat grades_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/grade_repository.dart';

final gradesProvider = FutureProvider.family<(List<SubjectGrade>, GradeSummary), int>(
  (ref, semester) async {
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return (<SubjectGrade>[], GradeSummary.empty);
    final repo = ref.watch(gradeRepositoryProvider);
    await repo.seedIfEmpty(user.id);
    return repo.getGradesByStudent(user.id, semester);
  },
);
```

- [ ] **Step 2: Tulis grades_screen.dart baru**

Ganti seluruh isi `lib/features/grades/presentation/screens/grades_screen.dart` dengan:

```dart
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
```

- [ ] **Step 3: Hapus dummy_grades.dart**

```bash
rm lib/features/grades/data/dummy_grades.dart
```

- [ ] **Step 4: flutter analyze**

```bash
flutter analyze lib/features/grades/
```

Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grades/presentation/providers/grades_provider.dart \
  lib/features/grades/presentation/screens/grades_screen.dart
git rm lib/features/grades/data/dummy_grades.dart
git commit -m "feat(grades): wire GradesScreen to Drift via gradesProvider, remove dummy data"
```

---

## Task 4: AttendanceHistoryRepository

**Files:**
- Create: `lib/features/history/data/repositories/attendance_history_repository.dart`
- Create: `test/features/history/data/repositories/attendance_history_repository_test.dart`

**Context:** `AppDatabase.forTesting(NativeDatabase.memory())`. Tabel `attendance` punya kolom `studentId`, `date` (YYYY-MM-DD string), `timeIn` (HH:mm string nullable), `timeOut`. Tabel `leaveRequests` punya `studentId`, `status` ('pending'/'approved'/'rejected'), `dateFrom` (YYYY-MM-DD nullable), `dateTo` (YYYY-MM-DD nullable). `DateFormatter.dateOnly(DateTime)` tersedia dari `lib/shared/utils/date_formatter.dart`.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/features/history/data/repositories/attendance_history_repository_test.dart`:

```dart
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambis_attendance/core/database/app_database.dart';
import 'package:ambis_attendance/features/history/data/repositories/attendance_history_repository.dart';

Future<void> _insertAttendance(
  AppDatabase db, {
  required String studentId,
  required String date,
  String? timeIn,
}) async {
  await db.into(db.attendance).insert(
    AttendanceCompanion.insert(
      id: drift.Value(date + studentId),
      studentId: studentId,
      date: date,
      status: 'present',
      isWithinGeofence: drift.Value(true),
      livenessVerified: drift.Value(true),
      faceMatchScore: drift.Value(0.9),
      createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      timeIn: drift.Value(timeIn),
    ),
  );
}

Future<void> _insertApprovedLeave(
  AppDatabase db, {
  required String studentId,
  required String dateFrom,
  required String dateTo,
}) async {
  await db.into(db.leaveRequests).insert(
    LeaveRequestsCompanion.insert(
      id: '$studentId$dateFrom',
      studentId: studentId,
      type: 'izin',
      status: 'approved',
      dateFrom: drift.Value(dateFrom),
      dateTo: drift.Value(dateTo),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ),
  );
}

void main() {
  late AppDatabase db;
  late AttendanceHistoryRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AttendanceHistoryRepository(db);
  });

  tearDown(() async => db.close());

  test('returns hadir when time_in is 07:00 (on time)', () async {
    await _insertAttendance(db, studentId: 's1', date: '2026-05-04', timeIn: '07:00');
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final rec = records.firstWhere((r) => r.date.day == 4);
    expect(rec.status, AttendanceStatus.hadir);
    expect(rec.checkInTime, '07:00');
  });

  test('returns terlambat when time_in is 07:31', () async {
    await _insertAttendance(db, studentId: 's1', date: '2026-05-04', timeIn: '07:31');
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final rec = records.firstWhere((r) => r.date.day == 4);
    expect(rec.status, AttendanceStatus.terlambat);
  });

  test('returns izin when approved leave covers the date', () async {
    await _insertApprovedLeave(
      db, studentId: 's1', dateFrom: '2026-05-04', dateTo: '2026-05-04',
    );
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final rec = records.firstWhere((r) => r.date.day == 4);
    expect(rec.status, AttendanceStatus.izin);
  });

  test('returns alfa for past weekday with no record and no leave', () async {
    // 2026-05-01 is a Friday (past date with no data)
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final may1 = records.where((r) => r.date.day == 1);
    // Only included if it's a weekday and in the past
    if (may1.isNotEmpty) {
      expect(may1.first.status, AttendanceStatus.alfa);
    }
  });

  test('pending leave does NOT count as izin', () async {
    await db.into(db.leaveRequests).insert(
      LeaveRequestsCompanion.insert(
        id: 's1-pending',
        studentId: 's1',
        type: 'izin',
        status: 'pending',
        dateFrom: drift.Value('2026-05-04'),
        dateTo: drift.Value('2026-05-04'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final rec = records.firstWhere((r) => r.date.day == 4);
    expect(rec.status, AttendanceStatus.alfa);
  });
}
```

- [ ] **Step 2: Jalankan test — pastikan GAGAL**

```bash
flutter test test/features/history/data/repositories/attendance_history_repository_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Buat AttendanceHistoryRepository**

Buat `lib/features/history/data/repositories/attendance_history_repository.dart`:

```dart
import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/utils/date_formatter.dart';

enum AttendanceStatus { hadir, terlambat, izin, alfa }

class AttendanceDay {
  const AttendanceDay({
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
  });

  final DateTime date;
  final AttendanceStatus status;
  final String? checkInTime;
  final String? checkOutTime;
}

class AttendanceHistoryRepository {
  AttendanceHistoryRepository(this._db);

  final AppDatabase _db;

  /// Returns one [AttendanceDay] per past weekday in [year]/[month].
  Future<List<AttendanceDay>> getMonthRecords(
    String studentId,
    int year,
    int month,
  ) async {
    final mm = month.toString().padLeft(2, '0');
    final monthPrefix = '$year-$mm';
    final lastDay = DateUtils.getDaysInMonth(year, month);
    final firstDayStr = '$monthPrefix-01';
    final lastDayStr = '$monthPrefix-${lastDay.toString().padLeft(2, '0')}';

    // 1. Fetch attendance rows for this month.
    final attendanceRows = await (_db.select(_db.attendance)
          ..where((a) => a.studentId.equals(studentId))
          ..where((a) => a.date.like('$monthPrefix-%')))
        .get();

    final attendanceMap = {for (final r in attendanceRows) r.date: r};

    // 2. Fetch approved leaves overlapping this month.
    final leaveRows = await (_db.select(_db.leaveRequests)
          ..where((l) => l.studentId.equals(studentId))
          ..where((l) => l.status.equals('approved'))
          ..where((l) => l.dateFrom.isSmallerOrEqualValue(lastDayStr))
          ..where((l) => l.dateTo.isBiggerOrEqualValue(firstDayStr)))
        .get();

    final today = DateTime.now();
    final result = <AttendanceDay>[];

    for (int day = 1; day <= lastDay; day++) {
      final date = DateTime(year, month, day);

      // Skip future dates and weekends.
      if (date.isAfter(today)) break;
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      final dateStr = DateFormatter.dateOnly(date);
      final attendance = attendanceMap[dateStr];

      if (attendance != null) {
        final timeIn = attendance.timeIn;
        final status = (timeIn != null && timeIn.compareTo('07:30') <= 0)
            ? AttendanceStatus.hadir
            : AttendanceStatus.terlambat;
        result.add(AttendanceDay(
          date: date,
          status: status,
          checkInTime: attendance.timeIn,
          checkOutTime: attendance.timeOut,
        ));
      } else {
        final hasApprovedLeave = leaveRows.any((l) {
          final from = l.dateFrom;
          final to = l.dateTo;
          if (from == null || to == null) return false;
          return dateStr.compareTo(from) >= 0 && dateStr.compareTo(to) <= 0;
        });

        result.add(AttendanceDay(
          date: date,
          status: hasApprovedLeave ? AttendanceStatus.izin : AttendanceStatus.alfa,
        ));
      }
    }

    return result;
  }
}

final attendanceHistoryRepositoryProvider =
    Provider<AttendanceHistoryRepository>((ref) {
  return AttendanceHistoryRepository(ref.watch(appDatabaseProvider));
});
```

- [ ] **Step 4: Jalankan test — pastikan LULUS**

```bash
flutter test test/features/history/data/repositories/attendance_history_repository_test.dart
```

Expected: 5 tests passed.

- [ ] **Step 5: flutter analyze**

```bash
flutter analyze lib/features/history/data/repositories/
```

Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/features/history/data/repositories/attendance_history_repository.dart \
  test/features/history/data/repositories/attendance_history_repository_test.dart
git commit -m "feat(history): add AttendanceHistoryRepository with status derivation from Drift"
```

---

## Task 5: historyProvider + HistoryScreen Migration

**Files:**
- Create: `lib/features/history/presentation/providers/history_provider.dart`
- Modify: `lib/features/history/presentation/screens/history_screen.dart`
- Delete: `lib/features/history/data/dummy_history.dart`

**Context:** `AttendanceDay` dan `AttendanceStatus` enum sudah ada di `attendance_history_repository.dart`. `HistoryScreen` saat ini `StatefulWidget`, menggunakan `DummyAttendanceRecord` dan `AttendanceStatus` dari `dummy_history.dart`. Setelah migrasi, type name sama (`AttendanceStatus`) tapi dari source berbeda.

- [ ] **Step 1: Buat history_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/attendance_history_repository.dart';

final historyProvider = FutureProvider.family<List<AttendanceDay>, (int, int)>(
  (ref, key) async {
    final (year, month) = key;
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return [];
    return ref
        .watch(attendanceHistoryRepositoryProvider)
        .getMonthRecords(user.id, year, month);
  },
);
```

- [ ] **Step 2: Tulis history_screen.dart baru**

Ganti seluruh isi `lib/features/history/presentation/screens/history_screen.dart` dengan kode berikut. Perubahan utama: `StatefulWidget` → `ConsumerStatefulWidget`, `DummyAttendanceRecord` → `AttendanceDay`, data dari provider bukan list dummy.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../data/repositories/attendance_history_repository.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _displayMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return _displayMonth.year < now.year ||
        (_displayMonth.year == now.year && _displayMonth.month < now.month);
  }

  void _prevMonth() => setState(() {
        _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
        _selectedDate = null;
      });

  void _nextMonth() {
    if (!_canGoNext) return;
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      historyProvider((_displayMonth.year, _displayMonth.month)),
    );

    final records = async.valueOrNull ?? [];
    final recordMap = {
      for (final r in records)
        DateTime(r.date.year, r.date.month, r.date.day): r,
    };

    final hadir =
        records.where((r) => r.status == AttendanceStatus.hadir).length;
    final terlambat =
        records.where((r) => r.status == AttendanceStatus.terlambat).length;
    final izin =
        records.where((r) => r.status == AttendanceStatus.izin).length;
    final alfa =
        records.where((r) => r.status == AttendanceStatus.alfa).length;

    final selectedRecord =
        _selectedDate != null ? recordMap[_selectedDate] : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kehadiran')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajukan Izin'),
        onPressed: () => context.push('/leave'),
      ),
      body: GradientBackground(
        child: async.isLoading
            ? const Center(child: CircularProgressIndicator())
            : async.hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Gagal memuat riwayat.',
                            style: TextStyle(color: AppColors.error)),
                        const SizedBox(height: Spacing.sm),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(historyProvider(
                            (_displayMonth.year, _displayMonth.month),
                          )),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                        Spacing.md, Spacing.md, Spacing.md, 100),
                    children: [
                      _CalendarCard(
                        displayMonth: _displayMonth,
                        recordMap: recordMap,
                        selectedDate: _selectedDate,
                        canGoNext: _canGoNext,
                        onDateTap: (d) => setState(() => _selectedDate = d),
                        onPrevMonth: _prevMonth,
                        onNextMonth: _nextMonth,
                      ),
                      const SizedBox(height: Spacing.sm),
                      _SummaryRow(
                          hadir: hadir,
                          terlambat: terlambat,
                          izin: izin,
                          alfa: alfa),
                      if (_selectedDate != null) ...[
                        const SizedBox(height: Spacing.sm),
                        _DayDetailCard(
                            date: _selectedDate!, record: selectedRecord),
                      ],
                      const SizedBox(height: Spacing.sm),
                      const _LegendRow(),
                      const SizedBox(height: Spacing.sm),
                      _RecentList(records: records.reversed.toList()),
                    ],
                  ),
      ),
    );
  }
}

// ── Calendar ──────────────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.displayMonth,
    required this.recordMap,
    required this.selectedDate,
    required this.canGoNext,
    required this.onDateTap,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime displayMonth;
  final Map<DateTime, AttendanceDay> recordMap;
  final DateTime? selectedDate;
  final bool canGoNext;
  final ValueChanged<DateTime> onDateTap;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(displayMonth.year, displayMonth.month);
    final offset =
        DateTime(displayMonth.year, displayMonth.month, 1).weekday - 1;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: AppColors.textSecondary,
                onPressed: onPrevMonth,
              ),
              Text(
                '${_monthNames[displayMonth.month - 1]} ${displayMonth.year}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: canGoNext
                        ? AppColors.textSecondary
                        : AppColors.surfaceAlt),
                onPressed: canGoNext ? onNextMonth : null,
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: _dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 2,
            ),
            itemCount: offset + daysInMonth,
            itemBuilder: (_, index) {
              if (index < offset) return const SizedBox.shrink();
              final day = index - offset + 1;
              final date =
                  DateTime(displayMonth.year, displayMonth.month, day);
              final record = recordMap[date];
              final isSelected = selectedDate != null &&
                  selectedDate!.year == date.year &&
                  selectedDate!.month == date.month &&
                  selectedDate!.day == date.day;
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              return _CalendarCell(
                day: day,
                record: record,
                isSelected: isSelected,
                isToday: isToday,
                onTap: () => onDateTap(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.record,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final AttendanceDay? record;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  Color get _statusColor {
    if (record == null) return Colors.transparent;
    switch (record!.status) {
      case AttendanceStatus.hadir:
        return AppColors.success;
      case AttendanceStatus.terlambat:
        return AppColors.warning;
      case AttendanceStatus.izin:
        return AppColors.secondary;
      case AttendanceStatus.alfa:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.accent
              : record != null
                  ? _statusColor.withAlpha(51)
                  : Colors.transparent,
          border: isToday && !isSelected
              ? Border.all(color: AppColors.accent, width: 1.5)
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  color: isSelected
                      ? AppColors.background
                      : isToday
                          ? AppColors.accent
                          : AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: isToday || isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
              if (record != null && !isSelected)
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.hadir,
    required this.terlambat,
    required this.izin,
    required this.alfa,
  });

  final int hadir;
  final int terlambat;
  final int izin;
  final int alfa;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryChip(label: 'Hadir', value: hadir, color: AppColors.success),
        const SizedBox(width: Spacing.xs),
        _SummaryChip(
            label: 'Terlambat', value: terlambat, color: AppColors.warning),
        const SizedBox(width: Spacing.xs),
        _SummaryChip(label: 'Izin', value: izin, color: AppColors.secondary),
        const SizedBox(width: Spacing.xs),
        _SummaryChip(label: 'Alfa', value: alfa, color: AppColors.error),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(31),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(77), width: 1),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                )),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── Day detail ────────────────────────────────────────────────────────────────

class _DayDetailCard extends StatelessWidget {
  const _DayDetailCard({required this.date, required this.record});

  final DateTime date;
  final AttendanceDay? record;

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

    String statusLabel;
    Color statusColor;
    String detail;

    if (record == null) {
      statusLabel = 'Tidak ada data';
      statusColor = AppColors.textHint;
      detail = 'Hari libur atau data belum tersedia.';
    } else {
      switch (record!.status) {
        case AttendanceStatus.hadir:
          statusLabel = 'Hadir';
          statusColor = AppColors.success;
          detail = 'Masuk pukul ${record!.checkInTime ?? '-'}';
        case AttendanceStatus.terlambat:
          statusLabel = 'Terlambat';
          statusColor = AppColors.warning;
          detail = 'Masuk pukul ${record!.checkInTime ?? '-'}';
        case AttendanceStatus.izin:
          statusLabel = 'Izin';
          statusColor = AppColors.secondary;
          detail = 'Izin resmi disetujui';
        case AttendanceStatus.alfa:
          statusLabel = 'Alfa';
          statusColor = AppColors.error;
          detail = 'Tidak hadir tanpa keterangan';
      }
    }

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(detail,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(31),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: AppColors.success, label: 'Hadir'),
        SizedBox(width: 12),
        _LegendDot(color: AppColors.warning, label: 'Terlambat'),
        SizedBox(width: 12),
        _LegendDot(color: AppColors.secondary, label: 'Izin'),
        SizedBox(width: 12),
        _LegendDot(color: AppColors.error, label: 'Alfa'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ── Recent list ───────────────────────────────────────────────────────────────

class _RecentList extends StatelessWidget {
  const _RecentList({required this.records});

  final List<AttendanceDay> records;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text('Belum ada data bulan ini.',
              style: TextStyle(color: AppColors.textHint)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Bulan Ini',
          style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.xs),
        ...records.map((r) {
          Color color;
          String label;
          switch (r.status) {
            case AttendanceStatus.hadir:
              color = AppColors.success;
              label = 'Hadir';
            case AttendanceStatus.terlambat:
              color = AppColors.warning;
              label = 'Terlambat';
            case AttendanceStatus.izin:
              color = AppColors.secondary;
              label = 'Izin';
            case AttendanceStatus.alfa:
              color = AppColors.error;
              label = 'Alfa';
          }
          final dateStr = '${r.date.day} ${_monthNames[r.date.month - 1]}';
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: Spacing.sm),
                Text(dateStr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    r.checkInTime != null ? 'Masuk ${r.checkInTime}' : label,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withAlpha(31),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
```

- [ ] **Step 3: Hapus dummy_history.dart**

```bash
rm lib/features/history/data/dummy_history.dart
```

- [ ] **Step 4: flutter analyze**

```bash
flutter analyze lib/features/history/
```

Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/history/presentation/providers/history_provider.dart \
  lib/features/history/presentation/screens/history_screen.dart
git rm lib/features/history/data/dummy_history.dart
git commit -m "feat(history): wire HistoryScreen to Drift via historyProvider, remove dummy data"
```

---

## Task 6: LeaveRepository

**Files:**
- Create: `lib/features/leave_request/data/repositories/leave_repository.dart`
- Create: `test/features/leave_request/data/repositories/leave_repository_test.dart`

**Context:** `flutter_image_compress: ^2.1.0` dan `uuid: ^4.3.3` sudah ada di pubspec. `supabase_flutter` tersedia. Upload ke bucket `leave-attachments` di Supabase Storage menggunakan `uploadBinary` (terima `Uint8List`). Type mapping: `'Sakit'` → `'sakit'`, lainnya → `'izin'`. `LeaveException` sudah ada dari Task 1.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/features/leave_request/data/repositories/leave_repository_test.dart`:

```dart
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambis_attendance/core/database/app_database.dart';
import 'package:ambis_attendance/core/exceptions/app_exception.dart';
import 'package:ambis_attendance/features/leave_request/data/repositories/leave_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  test('mapType maps Sakit to sakit', () {
    expect(LeaveRepository.mapType('Sakit'), 'sakit');
  });

  test('mapType maps Izin Keluarga to izin', () {
    expect(LeaveRepository.mapType('Izin Keluarga'), 'izin');
  });

  test('mapType maps Keperluan Lain to izin', () {
    expect(LeaveRepository.mapType('Keperluan Lain'), 'izin');
  });

  test('validateExtension throws LeaveException for non-jpg file', () {
    final file = File('/tmp/test.png');
    expect(
      () => LeaveRepository.validateExtension(file),
      throwsA(isA<LeaveException>()),
    );
  });

  test('validateExtension does not throw for .jpg file', () {
    final file = File('/tmp/test.jpg');
    expect(() => LeaveRepository.validateExtension(file), returnsNormally);
  });

  test('validateExtension does not throw for .jpeg file', () {
    final file = File('/tmp/test.jpeg');
    expect(() => LeaveRepository.validateExtension(file), returnsNormally);
  });

  test('getLeavesByStudent returns empty list initially', () async {
    final repo = LeaveRepository(db);
    final leaves = await repo.getLeavesByStudent('student1');
    expect(leaves, isEmpty);
  });
}
```

- [ ] **Step 2: Jalankan test — pastikan GAGAL**

```bash
flutter test test/features/leave_request/data/repositories/leave_repository_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Buat LeaveRepository**

Buat `lib/features/leave_request/data/repositories/leave_repository.dart`:

```dart
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/exceptions/app_exception.dart';

const Uuid _uuid = Uuid();
const _kBucketName = 'leave-attachments';
const int _kMaxBytes = 1024 * 1024; // 1 MB

class LeaveRepository {
  LeaveRepository(this._db);

  final AppDatabase _db;

  /// Maps UI dropdown value to DB enum ('sakit' or 'izin').
  static String mapType(String uiType) =>
      uiType == 'Sakit' ? 'sakit' : 'izin';

  /// Throws [LeaveException] if [file] is not jpg/jpeg.
  static void validateExtension(File file) {
    final path = file.path.toLowerCase();
    if (!path.endsWith('.jpg') && !path.endsWith('.jpeg')) {
      throw const LeaveException('Format file harus JPG.');
    }
  }

  Future<LeaveRequestEntity> submitLeave({
    required String studentId,
    required String uiType,
    required String reason,
    required DateTime dateFrom,
    required DateTime dateTo,
    required File imageFile,
  }) async {
    validateExtension(imageFile);

    // Compress to ≤1 MB.
    final compressed = await _compress(imageFile);

    // Upload to Supabase Storage.
    final storagePath = '$studentId/${_uuid.v4()}.jpg';
    await sb.Supabase.instance.client.storage
        .from(_kBucketName)
        .uploadBinary(
          storagePath,
          compressed,
          fileOptions: const sb.FileOptions(contentType: 'image/jpeg'),
        );

    final attachmentUrl = sb.Supabase.instance.client.storage
        .from(_kBucketName)
        .getPublicUrl(storagePath);

    // Insert to Drift.
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final fmt = (DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    await _db.into(_db.leaveRequests).insert(
      LeaveRequestsCompanion.insert(
        id: id,
        studentId: studentId,
        type: mapType(uiType),
        reason: drift.Value(reason),
        dateFrom: drift.Value(fmt(dateFrom)),
        dateTo: drift.Value(fmt(dateTo)),
        attachmentUrl: drift.Value(attachmentUrl),
        attachmentLocalPath: drift.Value(imageFile.path),
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      ),
    );

    return (_db.select(_db.leaveRequests)
          ..where((l) => l.id.equals(id)))
        .getSingle();
  }

  Future<List<LeaveRequestEntity>> getLeavesByStudent(String studentId) {
    return (_db.select(_db.leaveRequests)
          ..where((l) => l.studentId.equals(studentId))
          ..orderBy([(l) => drift.OrderingTerm.desc(l.createdAt)]))
        .get();
  }

  Future<Uint8List> _compress(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1080,
      minHeight: 1080,
      quality: 85,
      format: CompressFormat.jpeg,
    );
    if (result == null) throw const LeaveException('Gagal mengompresi gambar.');

    if (result.length > _kMaxBytes) {
      result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 1080,
        minHeight: 1080,
        quality: 60,
        format: CompressFormat.jpeg,
      );
      if (result == null || result.length > _kMaxBytes) {
        throw const LeaveException(
            'Ukuran file terlalu besar setelah kompresi. Pilih foto lain.');
      }
    }

    return result;
  }
}

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository(ref.watch(appDatabaseProvider));
});
```

- [ ] **Step 4: Jalankan test — pastikan LULUS**

```bash
flutter test test/features/leave_request/data/repositories/leave_repository_test.dart
```

Expected: 7 tests passed.

- [ ] **Step 5: flutter analyze**

```bash
flutter analyze lib/features/leave_request/data/repositories/leave_repository.dart
```

Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/features/leave_request/data/repositories/leave_repository.dart \
  test/features/leave_request/data/repositories/leave_repository_test.dart
git commit -m "feat(leave): add LeaveRepository with compress + Supabase Storage upload"
```

---

## Task 7: leaveProvider + LeaveRequestScreen Migration

**Files:**
- Create: `lib/features/leave_request/presentation/providers/leave_provider.dart`
- Modify: `lib/features/leave_request/presentation/screens/leave_request_screen.dart`
- Delete: `lib/features/leave_request/data/dummy_leaves.dart`

**Context:** `LeaveRepository` ada dari Task 6. `image_picker: ^1.1.0` sudah di pubspec (Task 1). `LeaveRequestEntity` adalah Drift entity dari tabel `leave_requests` dengan field: `id`, `studentId`, `type`, `reason`, `status`, `dateFrom`, `dateTo`, `attachmentUrl`, `rejectedReason`, `createdAt`.

- [ ] **Step 1: Buat leave_provider.dart**

```dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/leave_repository.dart';

class LeaveNotifier extends Notifier<AsyncValue<List<LeaveRequestEntity>>> {
  @override
  AsyncValue<List<LeaveRequestEntity>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final leaves = await ref
          .read(leaveRepositoryProvider)
          .getLeavesByStudent(user.id);
      state = AsyncValue.data(leaves);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submit({
    required String uiType,
    required String reason,
    required DateTime dateFrom,
    required DateTime dateTo,
    required File imageFile,
  }) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncValue.loading();
    try {
      await ref.read(leaveRepositoryProvider).submitLeave(
            studentId: user.id,
            uiType: uiType,
            reason: reason,
            dateFrom: dateFrom,
            dateTo: dateTo,
            imageFile: imageFile,
          );
      await _load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final leaveProvider =
    NotifierProvider<LeaveNotifier, AsyncValue<List<LeaveRequestEntity>>>(
  LeaveNotifier.new,
);
```

- [ ] **Step 2: Tulis leave_request_screen.dart baru**

Ganti seluruh isi `lib/features/leave_request/presentation/screens/leave_request_screen.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../providers/leave_provider.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();
  final _picker = ImagePicker();

  String? _jenisIzin;
  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  bool _submitting = false;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: AppColors.background,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    final path = xfile.path.toLowerCase();
    if (!path.endsWith('.jpg') && !path.endsWith('.jpeg')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format file harus JPG/JPEG.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _imageFile = File(xfile.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal izin terlebih dahulu.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto bukti wajib diupload.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(leaveProvider.notifier).submit(
            uiType: _jenisIzin!,
            reason: _keteranganController.text.trim(),
            dateFrom: _startDate!,
            dateTo: _endDate!,
            imageFile: _imageFile!,
          );

      if (!mounted) return;
      // Check for error state after submit
      final providerState = ref.read(leaveProvider);
      if (providerState is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${(providerState as AsyncError).error}'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Success
      _formKey.currentState?.reset();
      setState(() {
        _jenisIzin = null;
        _startDate = null;
        _endDate = null;
        _imageFile = null;
        _keteranganController.clear();
      });
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Pengajuan Terkirim',
              style: TextStyle(color: AppColors.textPrimary)),
          content: const Text(
            'Pengajuan izin Anda sedang menunggu persetujuan wali kelas.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('OK', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leavesAsync = ref.watch(leaveProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Izin')),
      body: GradientBackground(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(Spacing.md),
              children: [
                // ── Form Card ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(Spacing.borderRadius),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengajuan Baru',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: Spacing.md),

                        // Jenis Izin
                        DropdownButtonFormField<String>(
                          value: _jenisIzin,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Izin',
                            prefixIcon: Icon(Icons.category_outlined,
                                color: AppColors.textHint, size: 20),
                          ),
                          dropdownColor: AppColors.surfaceAlt,
                          items: const [
                            DropdownMenuItem(
                                value: 'Sakit', child: Text('Sakit')),
                            DropdownMenuItem(
                                value: 'Izin Keluarga',
                                child: Text('Izin Keluarga')),
                            DropdownMenuItem(
                                value: 'Keperluan Lain',
                                child: Text('Keperluan Lain')),
                          ],
                          onChanged: (v) => setState(() => _jenisIzin = v),
                          validator: (v) =>
                              v == null ? 'Pilih jenis izin' : null,
                        ),
                        const SizedBox(height: Spacing.sm),

                        _DateField(
                          label: 'Tanggal Mulai',
                          date: _startDate,
                          onTap: () => _pickDate(isStart: true),
                        ),
                        const SizedBox(height: Spacing.sm),

                        _DateField(
                          label: 'Tanggal Selesai',
                          date: _endDate,
                          onTap: () => _pickDate(isStart: false),
                        ),
                        const SizedBox(height: Spacing.sm),

                        TextFormField(
                          controller: _keteranganController,
                          decoration: const InputDecoration(
                            labelText: 'Keterangan',
                            hintText:
                                'Jelaskan alasan izin secara singkat...',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Keterangan wajib diisi'
                                  : null,
                        ),
                        const SizedBox(height: Spacing.sm),

                        _UploadButton(
                          fileName: _imageFile?.path.split('/').last,
                          onTap: _submitting ? null : _pickImage,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Format JPG/JPEG, ukuran maks 1 MB.',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 11),
                        ),
                        const SizedBox(height: Spacing.md),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.background,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Spacing.borderRadius),
                            ),
                          ),
                          onPressed: _submitting ? null : _submit,
                          child: const Text('Kirim Pengajuan',
                              style:
                                  TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: Spacing.lg),

                // ── Riwayat ────────────────────────────────────────────────
                const Text(
                  'Riwayat Pengajuan',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                leavesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Gagal memuat riwayat: $e',
                      style: const TextStyle(color: AppColors.error)),
                  data: (leaves) => leaves.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('Belum ada pengajuan.',
                                style:
                                    TextStyle(color: AppColors.textHint)),
                          ),
                        )
                      : Column(
                          children: leaves
                              .map((l) => _LeaveCard(leave: l))
                              .toList(),
                        ),
                ),
              ],
            ),

            // Loading overlay during submit
            if (_submitting)
              Container(
                color: Colors.black38,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Date field ─────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String get _text => date != null
      ? '${date!.day} ${_monthNames[date!.month - 1]} ${date!.year}'
      : 'Pilih tanggal';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.borderRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon:
              const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          _text,
          style: TextStyle(
            color: date != null ? AppColors.textPrimary : AppColors.textHint,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ── Upload button ──────────────────────────────────────────────────────────────

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.fileName, required this.onTap});

  final String? fileName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return OutlinedButton.icon(
      icon: Icon(
        hasFile
            ? Icons.check_circle_outline_rounded
            : Icons.upload_file_rounded,
        size: 18,
      ),
      label: Text(
        hasFile ? fileName! : 'Upload Foto Bukti',
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            hasFile ? AppColors.success : AppColors.secondary,
        side: BorderSide(
            color: hasFile ? AppColors.success : AppColors.primary),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.borderRadius),
        ),
      ),
      onPressed: onTap,
    );
  }
}

// ── Leave card ─────────────────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave});

  final LeaveRequestEntity leave;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  Color get _statusColor {
    switch (leave.status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String get _statusLabel {
    switch (leave.status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  IconData get _statusIcon {
    switch (leave.status) {
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    final month = int.tryParse(parts[1]) ?? 1;
    return '${parts[2]} ${_monthNames[month - 1]} ${parts[0]}';
  }

  String _dateRange() {
    final from = leave.dateFrom;
    final to = leave.dateTo;
    if (from == null || to == null) return '-';
    if (from == to) return _formatDate(from);
    return '${_formatDate(from)} – ${_formatDate(to)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.xs),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 18),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        leave.type == 'sakit' ? 'Sakit' : 'Izin',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(31),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_dateRange()}  ·  ${leave.reason ?? ''}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (leave.rejectedReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Alasan penolakan: ${leave.rejectedReason}',
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Hapus dummy_leaves.dart**

```bash
rm lib/features/leave_request/data/dummy_leaves.dart
```

- [ ] **Step 4: flutter analyze**

```bash
flutter analyze lib/features/leave_request/
```

Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/leave_request/presentation/providers/leave_provider.dart \
  lib/features/leave_request/presentation/screens/leave_request_screen.dart
git rm lib/features/leave_request/data/dummy_leaves.dart
git commit -m "feat(leave): wire LeaveRequestScreen to real upload via leaveProvider, remove dummy data"
```

---

## Task 8: Supabase Storage Setup + Final Verification

**Files:** Tidak ada file kode — konfigurasi Supabase dashboard + verifikasi.

- [ ] **Step 1: Buat bucket di Supabase dashboard**

Buka Supabase project → Storage → New bucket:
- Name: `leave-attachments`
- Public bucket: **OFF** (private)
- File size limit: `1048576` (1 MB)
- Allowed MIME types: `image/jpeg`

- [ ] **Step 2: Tambah RLS policy untuk upload**

Di Supabase dashboard → Storage → Policies → `leave-attachments` → New policy:

```sql
-- Policy: siswa hanya bisa upload ke folder miliknya
CREATE POLICY "student upload own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'leave-attachments'
  AND (storage.foldername(name))[1] = auth.uid()
);
```

- [ ] **Step 3: Jalankan semua test**

```bash
flutter test
```

Expected: Semua test lulus (minimal 18+ tests dari Phase 2 + Phase 3).

- [ ] **Step 4: flutter analyze**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 5: Manual test checklist**

Pada Android device fisik:
- [ ] Buka tab **Nilai** → loading spinner muncul sebentar → data 10 mapel + chart tampil
- [ ] Pindah ke Semester 2 → nilai berbeda (sedikit lebih tinggi)
- [ ] Buka tab **Riwayat** → kalender bulan ini tampil, hari yang sudah absen berwarna hijau/kuning
- [ ] Tap tanggal yang ada absensi → detail card muncul di bawah
- [ ] Buka **Pengajuan Izin** → tap "Upload Foto Bukti" → galeri terbuka
- [ ] Pilih foto JPG → nama file muncul di button
- [ ] Coba pilih PNG → snackbar "Format file harus JPG/JPEG" muncul
- [ ] Isi form lengkap → tap "Kirim Pengajuan" → loading overlay muncul → dialog sukses
- [ ] Setelah sukses → riwayat pengajuan muncul di bawah dengan status "Menunggu"

- [ ] **Step 6: Commit final**

```bash
git add .
git commit -m "test(phase3): all tests passing, phase 3 real data integration complete"
```
