/// Top-level app exception. UI layer should map these to user-friendly text.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class GeofenceException extends AppException {
  const GeofenceException(super.message);
}

class TimeWindowException extends AppException {
  const TimeWindowException(super.message);
}

class FaceMismatchException extends AppException {
  const FaceMismatchException(super.message, {this.score});
  final double? score;
}

class FaceNotEnrolledException extends AppException {
  const FaceNotEnrolledException(super.message);
}

class ModelLoadException extends AppException {
  const ModelLoadException(super.message);
}

class SyncException extends AppException {
  const SyncException(super.message);
}

class LivenessException extends AppException {
  const LivenessException(super.message);
}

class RateLimitException extends AppException {
  const RateLimitException(super.message);
}
