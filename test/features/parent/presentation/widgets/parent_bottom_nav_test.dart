import 'package:ambis_attendance/features/parent/presentation/widgets/parent_bottom_nav.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parentBottomNavIndexForRoute', () {
    test('maps parent routes to bottom navigation indexes', () {
      expect(parentBottomNavIndexForRoute('/parent-dashboard'), 0);
      expect(parentBottomNavIndexForRoute('/parent-grades'), 1);
      expect(parentBottomNavIndexForRoute('/parent-history'), 2);
    });

    test('falls back to dashboard for unknown routes', () {
      expect(parentBottomNavIndexForRoute('/unknown'), 0);
    });
  });
}
