import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/parent_login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/enrollment/presentation/screens/enrollment_screen.dart';
import '../../features/enrollment/presentation/screens/nisn_verification_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/grades/presentation/screens/grades_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/leave_request/presentation/screens/leave_request_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/parent/presentation/screens/parent_attendance_history_screen.dart';
import '../../features/parent/presentation/screens/parent_dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/app_shell.dart';

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
      GoRoute(
        path: '/attendance',
        builder: (_, __) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/parent-dashboard',
        builder: (_, __) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: '/parent-history',
        builder: (_, __) => const ParentAttendanceHistoryScreen(),
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

      if (user.role == 'ortu') {
        const authOnlyRoutes = {
          '/login', '/splash', '/welcome', '/parent-login', '/nisn-verify',
        };
        if (authOnlyRoutes.contains(loc)) return '/parent-dashboard';
        if (loc == '/enrollment' || loc.startsWith('/enroll-face/')) {
          return '/parent-dashboard';
        }
        return null;
      }

      if (user.role != 'siswa') {
        const authOnlyRoutes = {'/login', '/splash', '/welcome', '/parent-login', '/nisn-verify'};
        if (authOnlyRoutes.contains(loc)) return '/dashboard';
        return null;
      }

      // Logged-in siswa should not be on guest/public routes
      const guestRoutes = {'/login', '/splash', '/welcome', '/parent-login', '/nisn-verify'};
      if (guestRoutes.contains(loc)) {
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
