import 'package:ambis_attendance/core/services/realtime_refresh_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attendance changes refresh student and parent attendance views', () {
    expect(
      realtimeRefreshTargetsForTable('attendance'),
      containsAll([
        RealtimeRefreshTarget.dashboardAttendance,
        RealtimeRefreshTarget.attendanceHistory,
        RealtimeRefreshTarget.parentAttendance,
        RealtimeRefreshTarget.checkInReminder,
      ]),
    );
  });

  test('admin-managed grades refresh student, parent, and profile grades', () {
    expect(
      realtimeRefreshTargetsForTable('grades'),
      containsAll([
        RealtimeRefreshTarget.studentGrades,
        RealtimeRefreshTarget.parentGrades,
        RealtimeRefreshTarget.profileGrades,
      ]),
    );
  });

  test('user and student changes refresh auth and profile data', () {
    expect(
      realtimeRefreshTargetsForTable('users'),
      containsAll([
        RealtimeRefreshTarget.authUser,
        RealtimeRefreshTarget.profileStudent,
      ]),
    );
    expect(
      realtimeRefreshTargetsForTable('students'),
      containsAll([
        RealtimeRefreshTarget.profileStudent,
        RealtimeRefreshTarget.parentChildInfo,
      ]),
    );
  });
}
