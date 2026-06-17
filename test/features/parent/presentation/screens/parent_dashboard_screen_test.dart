import 'package:ambis_attendance/core/router/app_router.dart';
import 'package:ambis_attendance/features/auth/presentation/providers/auth_provider.dart';
import 'package:ambis_attendance/features/grades/data/repositories/grade_repository.dart';
import 'package:ambis_attendance/features/notifications/data/models/notification_model.dart';
import 'package:ambis_attendance/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:ambis_attendance/features/parent/data/repositories/parent_repository.dart';
import 'package:ambis_attendance/features/parent/presentation/providers/parent_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows teacher announcements on parent dashboard',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: _parentOverrides(),
        child: const MaterialApp(home: _ParentDashboardHost()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pengumuman Guru'), findsOneWidget);
    expect(find.text('Rapat wali murid'), findsOneWidget);
    expect(find.text('Nilai rapor sudah bisa dipantau.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('parent can navigate to grades route from bottom tab',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: _parentOverrides(),
        child: Consumer(
          builder: (context, ref, _) {
            return MaterialApp.router(
              routerConfig: ref.watch(goRouterProvider),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Nilai').last);
    await tester.pumpAndSettle();

    expect(find.text('Nilai Anak'), findsOneWidget);
    expect(find.text('Matematika'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

List<Override> _parentOverrides() {
  return [
    authProvider.overrideWith(() => _FakeAuthNotifier(_parentUser)),
    childInfoProvider.overrideWith((ref) async => _child),
    childAttendanceThisMonthProvider.overrideWith((ref) async => 7),
    childTodayAttendanceProvider.overrideWith(
      (ref) async => const ChildTodayAttendance(
        timeIn: '07:10',
        timeOut: '14:05',
        isPresent: true,
      ),
    ),
    childGradesSummaryProvider.overrideWith(
      (ref) async => const [
        ChildGradeRow(subject: 'Matematika', utsScore: 86, uasScore: 90),
      ],
    ),
    childOverallAverageProvider.overrideWith((ref) async => 88),
    childLeaveRequestsProvider.overrideWith((ref) async => const []),
    childGradesProvider.overrideWith(
      (ref, semester) async => (
        const [
          SubjectGrade(subject: 'Matematika', utsScore: 86, uasScore: 90),
        ],
        const GradeSummary(
          overallAverage: 88,
          predikat: 'B+',
          academicYear: '2025/2026',
        ),
      ),
    ),
    notificationsProvider.overrideWith(
      () => _FakeNotificationsNotifier([
        AppNotification(
          id: 'announcement-1',
          userId: _parentUser.id,
          type: AppNotificationType.announcement,
          title: 'Rapat wali murid',
          body: 'Nilai rapor sudah bisa dipantau.',
          isRead: false,
          createdAt: DateTime(2026, 6, 16, 8),
        ),
      ]),
    ),
  ];
}

class _ParentDashboardHost extends ConsumerWidget {
  const _ParentDashboardHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return Router(
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
  }
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._user);

  final UserEntity _user;

  @override
  Future<UserEntity?> build() async => _user;
}

class _FakeNotificationsNotifier extends NotificationsNotifier {
  _FakeNotificationsNotifier(this._notifications);

  final List<AppNotification> _notifications;

  @override
  Future<List<AppNotification>> build() async => _notifications;
}

const _parentUser = UserEntity(
  id: 'parent-1',
  nisn: 'PARENT-1',
  passwordHash: '',
  role: 'ortu',
  fullname: 'Budi',
  isActive: true,
  createdAt: 0,
  updatedAt: 0,
);

const _child = ChildStudentInfo(
  studentId: 'student-1',
  fullname: 'Fahmi Siddiq',
  nisn: '222105063',
  className: 'XI IPA 2',
);
