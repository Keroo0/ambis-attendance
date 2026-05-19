import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_preferences_model.dart';

class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._client);

  final SupabaseClient _client;

  Future<NotificationPreferences?> getPreferences(String userId) async {
    final rows = await _client
        .from('notification_preferences')
        .select()
        .eq('user_id', userId)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    return NotificationPreferences.fromMap(list.first as Map<String, dynamic>);
  }

  Future<void> upsert(NotificationPreferences prefs) async {
    await _client.from('notification_preferences').upsert(prefs.toMap());
  }
}
