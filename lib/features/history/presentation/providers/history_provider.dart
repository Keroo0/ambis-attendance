import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/attendance_history_repository.dart';

final historyProvider =
    FutureProvider.family<List<AttendanceDay>, (int, int)>(
  (ref, key) async {
    final (year, month) = key;
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return [];
    return ref
        .watch(attendanceHistoryRepositoryProvider)
        .getMonthRecords(user.id, year, month);
  },
);
