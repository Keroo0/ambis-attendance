import 'package:ambis_attendance/features/enrollment/presentation/screens/enrollment_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cameraPreviewCoverSizeForCircle', () {
    test('keeps portrait camera preview proportional while covering circle',
        () {
      final size = cameraPreviewCoverSizeForCircle(
        dimension: 284,
        aspectRatio: 0.75,
      );

      expect(size.width, 284);
      expect(size.height, closeTo(378.666, 0.001));
    });

    test('keeps landscape camera preview proportional while covering circle',
        () {
      final size = cameraPreviewCoverSizeForCircle(
        dimension: 284,
        aspectRatio: 16 / 9,
      );

      expect(size.width, closeTo(504.888, 0.001));
      expect(size.height, 284);
    });
  });

  group('cameraPreviewDisplayAspectRatio', () {
    test('uses inverted controller ratio in portrait orientation', () {
      expect(
        cameraPreviewDisplayAspectRatio(
          controllerAspectRatio: 16 / 9,
          orientation: DeviceOrientation.portraitUp,
        ),
        closeTo(9 / 16, 0.001),
      );
    });

    test('uses controller ratio in landscape orientation', () {
      expect(
        cameraPreviewDisplayAspectRatio(
          controllerAspectRatio: 16 / 9,
          orientation: DeviceOrientation.landscapeLeft,
        ),
        closeTo(16 / 9, 0.001),
      );
    });
  });
}
