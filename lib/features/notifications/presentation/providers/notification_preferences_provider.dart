import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/notification_preferences_model.dart';
import '../../data/repositories/notification_preferences_repository.dart';

final _repoProvider = Provider<NotificationPreferencesRepository>(
  (ref) => NotificationPreferencesRepository(Supabase.instance.client),
);

class NotificationPreferencesNotifier
    extends AutoDisposeAsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() async {
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return const NotificationPreferences(userId: '');
    final repo = ref.read(_repoProvider);
    return await repo.getPreferences(user.id) ??
        NotificationPreferences(userId: user.id);
  }

  Future<void> save(NotificationPreferences prefs) async {
    state = const AsyncValue.loading();
    await ref.read(_repoProvider).upsert(prefs);
    state = AsyncValue.data(prefs);
  }
}

final notificationPreferencesProvider = AsyncNotifierProvider.autoDispose<
    NotificationPreferencesNotifier, NotificationPreferences>(
  NotificationPreferencesNotifier.new,
);
