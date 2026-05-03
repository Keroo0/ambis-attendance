import 'package:ambis_attendance/features/attendance/presentation/providers/rate_limit_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RateLimitNotifier', () {
    late ProviderContainer container;
    late RateLimitNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(rateLimitProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('cooldown adalah 0 ketika belum ada sukses', () {
      expect(notifier.cooldownSecondsLeft(), 0);
    });

    test('cooldown positif segera setelah recordSuccess', () {
      notifier.recordSuccess();
      expect(notifier.cooldownSecondsLeft(), greaterThan(0));
    });

    test('tidak terkunci setelah 4 kegagalan', () {
      for (int i = 0; i < 4; i++) notifier.recordFailure();
      expect(notifier.lockSecondsLeft(), 0);
    });

    test('terkunci setelah 5 kegagalan', () {
      for (int i = 0; i < 5; i++) notifier.recordFailure();
      expect(notifier.lockSecondsLeft(), greaterThan(0));
    });

    test('recordSuccess mereset failCount dan menghapus lockout', () {
      for (int i = 0; i < 5; i++) notifier.recordFailure();
      notifier.recordSuccess();
      expect(notifier.lockSecondsLeft(), 0);
      expect(container.read(rateLimitProvider).failCount, 0);
    });

    test('failCount bertambah setiap kegagalan', () {
      notifier.recordFailure();
      notifier.recordFailure();
      expect(container.read(rateLimitProvider).failCount, 2);
    });
  });
}
