import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/face_repository.dart';

/// Checks if a student has an active face embedding in the local DB.
///
/// `autoDispose` agar cache dibuang saat tidak ada listener — mencegah
/// hasil `false` lama tertinggal di memori setelah user selesai enrolment.
/// Tetap perlu `ref.invalidate(hasEnrolledFaceProvider)` setelah save
/// embedding kalau screen attendance sedang aktif di stack.
final hasEnrolledFaceProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) async {
  final faceRepo = ref.watch(faceRepositoryProvider);
  return faceRepo.hasActiveEmbedding(userId);
});
