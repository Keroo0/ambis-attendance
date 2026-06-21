import 'package:ambis_attendance/features/attendance/data/repositories/attendance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildFaceRecognitionLogPayload', () {
    test('builds thesis metrics payload for a successful genuine attempt', () {
      final payload = buildFaceRecognitionLogPayload(
        studentId: 'student-1',
        attendanceId: 'attendance-1',
        score: 0.874,
        threshold: 0.75,
        passed: true,
        livenessVerified: true,
        durationMs: 321,
        nowMs: 1710000000000,
      );

      expect(payload['student_id'], 'student-1');
      expect(payload['attendance_id'], 'attendance-1');
      expect(payload['attempt_type'], 'genuine');
      expect(payload['source'], 'attendance');
      expect(payload['face_match_score'], 0.874);
      expect(payload['threshold'], 0.75);
      expect(payload['passed'], isTrue);
      expect(payload['liveness_verified'], isTrue);
      expect(payload['failure_reason'], isNull);
      expect(payload['duration_ms'], 321);
      expect(payload['created_at'], 1710000000000);
    });

    test('builds failure payload without attendance id', () {
      final payload = buildFaceRecognitionLogPayload(
        studentId: 'student-2',
        score: 0.62,
        threshold: 0.75,
        passed: false,
        livenessVerified: true,
        failureReason: 'face_mismatch',
        durationMs: 88,
        nowMs: 1710000000001,
      );

      expect(payload['student_id'], 'student-2');
      expect(payload['attendance_id'], isNull);
      expect(payload['passed'], isFalse);
      expect(payload['failure_reason'], 'face_mismatch');
      expect(payload['created_at'], 1710000000001);
    });
  });
}
