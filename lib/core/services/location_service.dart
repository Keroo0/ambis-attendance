import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_constants.dart';
import '../exceptions/app_exception.dart';

class LocationService {
  /// Returns the current device position. Asks for permission as needed.
  /// Throws [GeofenceException] when permission is denied or services off.
  Future<Position> getCurrentPosition() async {
    final servicesOn = await Geolocator.isLocationServiceEnabled();
    if (!servicesOn) {
      throw const GeofenceException(
        'Layanan lokasi (GPS) belum aktif. Aktifkan terlebih dahulu.',
      );
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      throw const GeofenceException(
        'Izin lokasi diblokir permanen. Buka pengaturan untuk mengaktifkan.',
      );
    }
    if (perm == LocationPermission.denied) {
      throw const GeofenceException('Izin lokasi ditolak.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  /// Haversine distance between two WGS-84 coordinates in metres.
  static double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _deg2rad(double deg) => deg * math.pi / 180.0;

  static double distanceToSchool(Position p) {
    return haversineMeters(
      p.latitude,
      p.longitude,
      AppConstants.schoolLat,
      AppConstants.schoolLng,
    );
  }

  static bool isWithinGeofence(Position p, {double? radiusMeters}) {
    final r = radiusMeters ?? AppConstants.geofenceRadiusMeters;
    return distanceToSchool(p) <= r;
  }

  /// Mock-GPS detection is deferred to Phase 2. We surface the platform flag
  /// so callers can wire a real check later without a refactor.
  static bool isMocked(Position p) {
    return p.isMocked;
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
