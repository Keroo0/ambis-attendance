import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/face_repository.dart';

/// Checks if a student has an active face embedding in the local DB.
final hasEnrolledFaceProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final faceRepo = ref.watch(faceRepositoryProvider);
  return faceRepo.hasActiveEmbedding(userId);
});
