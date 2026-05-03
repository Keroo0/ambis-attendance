import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../data/repositories/sync_repository.dart';

/// Triggers `syncPendingAttendance` on:
///   1. App resume (`AppLifecycleState.resumed`).
///   2. Supabase auth state changes (login / token refresh).
///   3. Manual call to `triggerNow`.
///
/// Without `connectivity_plus` we can't react to network restore, so we
/// also fire once on startup and let resume cover the airplane-mode flow.
class SyncCoordinator with WidgetsBindingObserver {
  SyncCoordinator(this._ref);

  final Ref _ref;
  StreamSubscription<sb.AuthState>? _authSub;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _authSub = sb.Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      unawaited(triggerNow());
    });
    unawaited(triggerNow());
  }

  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    _authSub = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(triggerNow());
    }
  }

  Future<SyncResult> triggerNow() async {
    final result =
        await _ref.read(syncRepositoryProvider).syncPendingAttendance();
    // Refresh the badge after each run.
    // ignore: unused_result
    _ref.invalidate(pendingSyncCountProvider);
    return result;
  }
}

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final coord = SyncCoordinator(ref);
  ref.onDispose(coord.stop);
  return coord;
});
