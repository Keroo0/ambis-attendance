import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationsNotifier
    extends AutoDisposeAsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return [];
    return ref
        .read(notificationRepositoryProvider)
        .getNotifications(user.id);
  }

  Future<void> markAsRead(String notificationId) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAsRead(notificationId);
    state = AsyncData(
      state.valueOrNull
              ?.map((n) =>
                  n.id == notificationId ? n.copyWith(isRead: true) : n)
              .toList() ??
          [],
    );
  }

  Future<void> markAllAsRead() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead(user.id);
    state = AsyncData(
      state.valueOrNull
              ?.map((n) => n.copyWith(isRead: true))
              .toList() ??
          [],
    );
  }
}

final notificationsProvider =
    AsyncNotifierProvider.autoDispose<NotificationsNotifier,
        List<AppNotification>>(
  NotificationsNotifier.new,
);
