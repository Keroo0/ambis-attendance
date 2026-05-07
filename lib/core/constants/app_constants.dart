/// Project-wide constants. Replace placeholder values before running on device.
class AppConstants {
  AppConstants._();

  static const String appName = 'AMBIS Attendance';
  static const String schoolName = 'SMAN 07 Kabupaten Tangerang';

  // TODO(config): replace with real coordinates of SMAN 07 Kabupaten Tangerang.
  // Current value is the centroid of Kabupaten Tangerang as a stub.
  static const double schoolLat = -6.1783;
  static const double schoolLng = 106.6319;

  /// Geofence radius in meters (CLAUDE_UPDATED.md §"GPS geofence 50m").
  static const double geofenceRadiusMeters = 50.0;

  /// Default cosine similarity threshold for face matching.
  /// Override at runtime via the `settings` table key
  /// `face_recognition_threshold`.
  static const double defaultFaceThreshold = 0.75;

  /// Embedding dimensionality — model outputs 192-D vectors.
  static const int embeddingSize = 192;

  /// MobileFaceNet expects 112x112 RGB input, normalised to [-1, 1].
  static const int faceInputSize = 112;

  /// Suffix used to map a NISN onto a Supabase Auth email so we can reuse
  /// Supabase Auth without adding a hashing dependency on-device.
  static const String authEmailDomain = 'sman07.local';

  /// Time-window defaults (overridable via `settings` table).
  static const String defaultTimeInStart = '06:00';
  static const String defaultTimeInEnd = '07:30';
  static const String defaultTimeOutStart = '14:00';
  static const String defaultTimeOutEnd = '16:00';
}
