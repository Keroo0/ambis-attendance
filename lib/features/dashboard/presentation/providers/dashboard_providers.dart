import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../enrollment/data/repositories/face_repository.dart';

final dashboardHasFaceDataProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return true;
  return ref.read(faceRepositoryProvider).hasActiveEmbedding(user.id);
});

final dashboardTodayAttendanceProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  final today = _todayStr();
  final rows = await Supabase.instance.client
      .from('attendance')
      .select()
      .eq('student_id', user.id)
      .eq('date', today)
      .limit(1);
  final list = rows as List;
  return list.isEmpty ? null : list.first as Map<String, dynamic>;
});

final dashboardRecentAttendanceProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return [];
  final rows = await Supabase.instance.client
      .from('attendance')
      .select()
      .eq('student_id', user.id)
      .order('date', ascending: false)
      .limit(5);
  return (rows as List).cast<Map<String, dynamic>>();
});

String _todayStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
