import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/leave_repository.dart';

class LeaveNotifier
    extends Notifier<AsyncValue<List<Map<String, dynamic>>>> {
  @override
  AsyncValue<List<Map<String, dynamic>>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final leaves = await ref
          .read(leaveRepositoryProvider)
          .getLeavesByStudent(user.id);
      state = AsyncValue.data(leaves);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submit({
    required String uiType,
    required String reason,
    required DateTime dateFrom,
    required DateTime dateTo,
    required File imageFile,
  }) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncValue.loading();
    try {
      await ref.read(leaveRepositoryProvider).submitLeave(
            studentId: user.id,
            uiType: uiType,
            reason: reason,
            dateFrom: dateFrom,
            dateTo: dateTo,
            imageFile: imageFile,
          );
      await _load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final leaveProvider = NotifierProvider<LeaveNotifier,
    AsyncValue<List<Map<String, dynamic>>>>(
  LeaveNotifier.new,
);
