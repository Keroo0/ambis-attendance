import 'dart:typed_data';
import 'dart:math' as math;

import 'package:ambis_attendance/core/constants/app_constants.dart';
import 'package:ambis_attendance/core/services/location_service.dart';
import 'package:ambis_attendance/features/enrollment/data/repositories/face_repository.dart';
import 'package:ambis_attendance/shared/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FaceRepository.cosineSimilarity', () {
    test('identical L2-normalised vectors → 1.0', () {
      final norm = math.sqrt(AppConstants.embeddingSize);
      final a = Float32List.fromList(
        List.generate(AppConstants.embeddingSize, (i) => 1 / norm),
      );
      expect(
        FaceRepository.cosineSimilarity(a, a),
        closeTo(1.0, 1e-3),
      );
    });

    test('orthogonal vectors → 0.0', () {
      final a = Float32List(AppConstants.embeddingSize);
      final b = Float32List(AppConstants.embeddingSize);
      a[0] = 1.0;
      b[1] = 1.0;
      expect(FaceRepository.cosineSimilarity(a, b), 0.0);
    });
  });

  group('LocationService.haversineMeters', () {
    test('zero distance for identical points', () {
      expect(
        LocationService.haversineMeters(-6.1783, 106.6319, -6.1783, 106.6319),
        closeTo(0.0, 0.001),
      );
    });

    test('~111 km per degree of latitude', () {
      final d = LocationService.haversineMeters(0, 0, 1, 0); // 1° lat ≈ 111 km
      expect(d, greaterThan(110000));
      expect(d, lessThan(112000));
    });
  });

  group('DateFormatter.isWithinWindow', () {
    test('inside window', () {
      const now = Duration(hours: 6, minutes: 30);
      expect(DateFormatter.isWithinWindow(now, '06:00', '07:30'), isTrue);
    });
    test('outside window', () {
      const now = Duration(hours: 8, minutes: 0);
      expect(DateFormatter.isWithinWindow(now, '06:00', '07:30'), isFalse);
    });
  });
}
