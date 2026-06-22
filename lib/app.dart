import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/realtime_refresh_service.dart';
import 'features/attendance/presentation/providers/sync_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'shared/themes/app_theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Wire foreground / auth-change sync triggers as soon as the tree mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(syncCoordinatorProvider).start();
      ref.read(realtimeRefreshCoordinatorProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, next) {
      final user = next.valueOrNull;
      if (user?.role == 'siswa') {
        unawaited(
          ref
              .read(notificationServiceProvider)
              .startCheckInReminder(studentId: user!.id),
        );
      } else if (user == null) {
        unawaited(ref.read(notificationServiceProvider).cancelReminder());
      }
    });

    final router = ref.watch(goRouterProvider);
    return ToastificationWrapper(
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
