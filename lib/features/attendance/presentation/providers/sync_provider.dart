import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../data/repositories/sync_repository.dart';

/// Triggers `syncPendingFaceEmbeddings` on:
///   1. App resume (`AppLifecycleState.resumed`).
///   2. Supabase auth state changes (login / token refresh).
///   3. Manual call to `triggerNow`.
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
    final repo = _ref.read(syncRepositoryProvider);
    return repo.syncPendingFaceEmbeddings();
  }
}

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final coord = SyncCoordinator(ref);
  ref.onDispose(coord.stop);
  return coord;
});
