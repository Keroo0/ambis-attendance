import 'package:flutter_riverpod/flutter_riverpod.dart';

class RateLimitState {
  const RateLimitState({
    this.lastSuccess,
    this.failCount = 0,
    this.lockedUntil,
  });

  final DateTime? lastSuccess;
  final int failCount;
  final DateTime? lockedUntil;
}

class RateLimitNotifier extends Notifier<RateLimitState> {
  @override
  RateLimitState build() => const RateLimitState();

  /// Sisa detik cooldown setelah sukses terakhir (0 = boleh lanjut).
  int cooldownSecondsLeft() {
    final last = state.lastSuccess;
    if (last == null) return 0;
    final elapsed = DateTime.now().difference(last).inSeconds;
    return (30 - elapsed).clamp(0, 30);
  }

  /// Sisa detik lockout (0 = tidak terkunci).
  int lockSecondsLeft() {
    final until = state.lockedUntil;
    if (until == null) return 0;
    return until.difference(DateTime.now()).inSeconds.clamp(0, 300);
  }

  void recordSuccess() {
    state = RateLimitState(lastSuccess: DateTime.now());
  }

  void recordFailure() {
    final newCount = state.failCount + 1;
    state = RateLimitState(
      lastSuccess: state.lastSuccess,
      failCount: newCount,
      lockedUntil: newCount >= 5
          ? DateTime.now().add(const Duration(minutes: 5))
          : state.lockedUntil,
    );
  }
}

final rateLimitProvider =
    NotifierProvider<RateLimitNotifier, RateLimitState>(RateLimitNotifier.new);
