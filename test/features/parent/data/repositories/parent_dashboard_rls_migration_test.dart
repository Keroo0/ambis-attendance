import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parent dashboard migration adds only missing child read policies', () {
    final migration = File(
      'supabase/migrations/20260620_fix_parent_dashboard_rls.sql',
    );

    expect(migration.existsSync(), isTrue);

    final sql = migration.readAsStringSync();
    expect(sql, contains('create schema if not exists private'));
    expect(sql, contains('private.is_parent_of_student'));
    expect(sql, contains('security definer'));
    expect(sql, contains('parent_dashboard_read_child_user'));
    expect(sql, contains('parent_dashboard_read_child_grades'));
    expect(sql, contains('parent_dashboard_read_child_attendance'));
    expect(sql, contains('parent_dashboard_read_child_leave_requests'));
    expect(sql, contains('s.parent_id = auth.uid()'));
    expect(sql, isNot(contains('grant select')));
    expect(sql, isNot(contains('parent_dashboard_read_child_student')));
  });
}
