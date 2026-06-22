import 'package:ambis_attendance/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNotificationService extends NotificationService {
  final calls = <String>[];

  @override
  Future<void> initialize() async {
    calls.add('initialize');
  }

  @override
  Future<void> requestPermission() async {
    calls.add('requestPermission');
  }

  @override
  Future<void> scheduleCheckInReminder({String? studentId}) async {
    calls.add('scheduleCheckInReminder:$studentId');
  }
}

void main() {
  test('startCheckInReminder initializes, requests permission, then schedules',
      () async {
    final service = _FakeNotificationService();

    await service.startCheckInReminder(studentId: 'student-1');

    expect(service.calls, [
      'initialize',
      'requestPermission',
      'scheduleCheckInReminder:student-1',
    ]);
  });
}
