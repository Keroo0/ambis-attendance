import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';

class GeofenceSettings {
  final bool enabled;
  final double lat;
  final double lng;
  final double radius;

  const GeofenceSettings({
    required this.enabled,
    required this.lat,
    required this.lng,
    required this.radius,
  });
}

/// Reads geofence settings from the `settings` Supabase table.
/// Falls back to AppConstants defaults if keys are missing or query fails.
final geofenceSettingsProvider = FutureProvider<GeofenceSettings>((ref) async {
  final response = await Supabase.instance.client
      .from('settings')
      .select('key, value')
      .inFilter('key', [
        'geofence_enabled',
        'school_lat',
        'school_lng',
        'geofence_radius',
      ]);

  final rows = response as List<dynamic>;
  final map = <String, String>{
    for (final row in rows) row['key'] as String: row['value'] as String,
  };

  return GeofenceSettings(
    enabled: map['geofence_enabled'] != 'false',
    lat: double.tryParse(map['school_lat'] ?? '') ?? AppConstants.schoolLat,
    lng: double.tryParse(map['school_lng'] ?? '') ?? AppConstants.schoolLng,
    radius: double.tryParse(map['geofence_radius'] ?? '') ??
        AppConstants.geofenceRadiusMeters,
  );
});
