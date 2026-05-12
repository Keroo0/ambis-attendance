import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'features/attendance/presentation/providers/sync_provider.dart';
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
      // Jadwalkan ulang reminder absen setiap buka app
      await ref.read(notificationServiceProvider).scheduleCheckInReminder();
    });
  }

  @override
  Widget build(BuildContext context) {
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
