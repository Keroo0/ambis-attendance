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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RateLimitState &&
        other.lastSuccess == lastSuccess &&
        other.failCount == failCount &&
        other.lockedUntil == lockedUntil;
  }

  @override
  int get hashCode => Object.hash(lastSuccess, failCount, lockedUntil);
}

class RateLimitNotifier extends Notifier<RateLimitState> {
  static const int _kCooldownSeconds = 30;
  static const int _kLockoutSeconds = 5 * 60;

  @override
  RateLimitState build() => const RateLimitState();

  /// Sisa detik cooldown setelah sukses terakhir (0 = boleh lanjut).
  int cooldownSecondsLeft() {
    final last = state.lastSuccess;
    if (last == null) return 0;
    final elapsed = DateTime.now().difference(last).inSeconds;
    return (_kCooldownSeconds - elapsed).clamp(0, _kCooldownSeconds);
  }

  /// Sisa detik lockout (0 = tidak terkunci).
  int lockSecondsLeft() {
    final until = state.lockedUntil;
    if (until == null) return 0;
    return until.difference(DateTime.now()).inSeconds.clamp(0, _kLockoutSeconds);
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
          ? DateTime.now().add(const Duration(seconds: _kLockoutSeconds))
          : state.lockedUntil,
    );
  }
}

final rateLimitProvider =
    NotifierProvider<RateLimitNotifier, RateLimitState>(RateLimitNotifier.new);
