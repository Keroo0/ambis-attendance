import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';

export '../../data/models/user_entity.dart';

/// Async state of the currently signed-in user (null = signed out).
class AuthNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    final repo = ref.read(authRepositoryProvider);
    return repo.getCurrentUser();
  }

  Future<void> login(String nisn, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.login(nisn: nisn, password: password);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      return null;
    });
  }

  Future<void> refreshUser() async {
    final updated = await ref.read(authRepositoryProvider).getCurrentUser();
    if (updated != null) state = AsyncData(updated);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(
  AuthNotifier.new,
);
