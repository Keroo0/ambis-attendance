import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/grade_repository.dart';

final gradesProvider = FutureProvider.family<(List<SubjectGrade>, GradeSummary), int>(
  (ref, semester) async {
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return (<SubjectGrade>[], GradeSummary.empty);
    final repo = ref.watch(gradeRepositoryProvider);
    await repo.seedIfEmpty(user.id);
    return repo.getGradesByStudent(user.id, semester);
  },
);
