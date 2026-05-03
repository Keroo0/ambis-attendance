// Conditional export: TFLite (dart:ffi) is unavailable on web, so we swap in
// a stub implementation that preserves the API but throws on TFLite methods.
export 'face_repository_native.dart'
    if (dart.library.html) 'face_repository_web.dart';
