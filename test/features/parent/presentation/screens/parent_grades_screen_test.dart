import 'package:ambis_attendance/features/grades/data/repositories/grade_repository.dart';
import 'package:ambis_attendance/features/parent/data/repositories/parent_repository.dart';
import 'package:ambis_attendance/features/parent/presentation/providers/parent_provider.dart';
import 'package:ambis_attendance/features/parent/presentation/screens/parent_grades_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders child grades without layout errors', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          childInfoProvider.overrideWith((ref) async {
            return const ChildStudentInfo(
              studentId: 'student-1',
              fullname: 'Fahmi Siddiq',
              nisn: '222105063',
              className: 'XI IPA 2',
            );
          }),
          childGradesProvider.overrideWith((ref, semester) async {
            return (
              const [
                SubjectGrade(
                  subject: 'Matematika',
                  utsScore: 86,
                  uasScore: 90,
                ),
                SubjectGrade(
                  subject: 'Bahasa Indonesia',
                  utsScore: 82,
                  uasScore: 84,
                ),
              ],
              const GradeSummary(
                overallAverage: 72.5,
                predikat: 'C',
                academicYear: '2025/2026',
              ),
            );
          }),
        ],
        child: const MaterialApp(
          home: ParentGradesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nilai Anak'), findsOneWidget);
    expect(find.text('Fahmi Siddiq'), findsOneWidget);
    expect(find.text('Matematika'), findsOneWidget);
    expect(find.text('72.5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
