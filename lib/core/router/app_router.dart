import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/parent_login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/enrollment/presentation/screens/enrollment_screen.dart';
import '../../features/enrollment/presentation/screens/nisn_verification_screen.dart';
import '../../features/grades/presentation/screens/grades_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/leave_request/presentation/screens/leave_request_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../database/app_database.dart';

/// Polls the local DB for whether [userId] has an active face embedding.
/// Cached so the router doesn't query on every redirect.
final hasEnrolledFaceProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final db = ref.watch(appDatabaseProvider);
  final row = await (db.select(db.faceEmbeddings)
        ..where((e) => e.studentId.equals(userId))
        ..where((e) => e.isActive.equals(true))
        ..limit(1))
      .getSingleOrNull();
  return row != null;
});

class _AuthRouterListenable extends ChangeNotifier {
  _AuthRouterListenable(this._ref) {
    _sub = _ref.listen<AsyncValue<UserEntity?>>(
      authProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }
  final Ref _ref;
  late final ProviderSubscription<AsyncValue<UserEntity?>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

GoRouter buildRouter(Ref ref) {
  final listenable = _AuthRouterListenable(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/parent-login',
        builder: (_, __) => const ParentLoginScreen(),
      ),
      GoRoute(
        path: '/nisn-verify',
        builder: (_, __) => const NisnVerificationScreen(),
      ),
      GoRoute(
        path: '/enrollment',
        builder: (_, __) => const EnrollmentScreen(),
      ),
      GoRoute(
        path: '/enroll-face/:userId',
        builder: (_, state) => EnrollmentScreen(
          guestUserId: state.pathParameters['userId'],
        ),
      ),
      GoRoute(
        path: '/attendance',
        builder: (_, __) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/leave',
        builder: (_, __) => const LeaveRequestScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const HistoryScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/grades',
                builder: (_, __) => const GradesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      // While auth is still resolving (cold start), keep on splash.
      // Exception: don't interrupt /login — it shows its own spinner during login.
      if (auth.isLoading) {
        if (loc == '/login') return null;
        return loc == '/splash' ? null : '/splash';
      }

      final user = auth.valueOrNull;
      final loggedIn = user != null;

      if (!loggedIn) {
        const guestRoutes = {'/welcome', '/login', '/parent-login', '/nisn-verify'};
        if (guestRoutes.contains(loc) || loc.startsWith('/enroll-face/')) {
          return null;
        }
        return '/welcome';
      }

      // Logged in. Now check enrollment for siswa role only.
      if (user.role != 'siswa') {
        const authOnlyRoutes = {'/login', '/splash', '/welcome', '/parent-login', '/nisn-verify'};
        if (authOnlyRoutes.contains(loc)) return '/dashboard';
        return null;
      }

      final enrolled =
          ref.read(hasEnrolledFaceProvider(user.id)).valueOrNull;
      // While enrollment query is loading, keep current page (avoid flicker).
      if (enrolled == null) {
        if (loc == '/login' || loc == '/splash') return '/dashboard';
        return null;
      }

      if (!enrolled && loc != '/enrollment') {
        return '/enrollment';
      }
      if (enrolled &&
          (loc == '/login' ||
              loc == '/splash' ||
              loc == '/welcome' ||
              loc == '/parent-login' ||
              loc == '/nisn-verify')) {
        return '/dashboard';
      }
      return null;
    },
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = buildRouter(ref);
  ref.onDispose(router.dispose);
  return router;
});
