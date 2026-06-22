import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('realtime publication migration enables app data tables', () {
    final sql = File(
      'supabase/migrations/20260622_enable_mobile_realtime_tables.sql',
    ).readAsStringSync();

    for (final table in [
      'attendance',
      'grades',
      'leave_requests',
      'notifications',
      'notification_preferences',
      'users',
      'students',
      'settings',
    ]) {
      expect(sql, contains("'$table'"));
    }
    expect(sql, contains('alter publication supabase_realtime add table'));
  });
}
