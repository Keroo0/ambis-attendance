import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/parent_repository.dart';

/// Fetch child student info (name, nisn, class) for the logged-in parent.
final childInfoProvider =
    FutureProvider.autoDispose<ChildStudentInfo?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(parentRepositoryProvider).getChildInfo(user.id);
});

/// Fetch top UTS grades for the child.
final childGradesSummaryProvider =
    FutureProvider.autoDispose<List<ChildGradeRow>>((ref) async {
  final child = ref.watch(childInfoProvider).valueOrNull;
  if (child == null) return [];
  return ref
      .read(parentRepositoryProvider)
      .getChildGradesSummary(child.studentId);
});

/// Fetch overall grade average for the child.
final childOverallAverageProvider =
    FutureProvider.autoDispose<double?>((ref) async {
  final child = ref.watch(childInfoProvider).valueOrNull;
  if (child == null) return null;
  return ref
      .read(parentRepositoryProvider)
      .getChildOverallAverage(child.studentId);
});

/// Count of attended (hadir) days for the child in the current calendar month.
final childAttendanceThisMonthProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final child = ref.watch(childInfoProvider).valueOrNull;
  if (child == null) return 0;
  final now = DateTime.now();
  return ref
      .read(parentRepositoryProvider)
      .getChildAttendanceCountThisMonth(child.studentId, now.year, now.month);
});

/// Full attendance summary for the child in [year]/[month].
final childAttendanceProvider = FutureProvider.autoDispose
    .family<ParentAttendanceSummary, (int, int)>((ref, key) async {
  final (year, month) = key;
  final child = ref.watch(childInfoProvider).valueOrNull;
  if (child == null) return ParentAttendanceSummary.empty;
  return ref
      .read(parentRepositoryProvider)
      .getChildAttendanceForMonth(child.studentId, year, month);
});
