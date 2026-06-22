import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../grades/data/repositories/grade_repository.dart';

final profileGradeSummaryProvider =
    FutureProvider.autoDispose<GradeSummary?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  final repo = ref.read(gradeRepositoryProvider);
  final now = DateTime.now();
  final semester = now.month >= 7 ? 1 : 2;
  final result = await repo.getGradesFromSupabase(user.id, semester);
  return result.$2;
});

final profileHomeroomTeacherProvider =
    FutureProvider.autoDispose<String?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  try {
    final row = await sb.Supabase.instance.client
        .from('students')
        .select('homeroom_teacher')
        .eq('id', user.id)
        .maybeSingle();
    return row?['homeroom_teacher'] as String?;
  } catch (_) {
    return null;
  }
});

final profileStudentProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  try {
    final row = await sb.Supabase.instance.client
        .from('students')
        .select(
          'id, nisn, class, parent_id, date_of_birth, gender, address, phone_parent, created_at, updated_at',
        )
        .eq('id', user.id)
        .maybeSingle();
    return row;
  } catch (_) {
    return null;
  }
});
