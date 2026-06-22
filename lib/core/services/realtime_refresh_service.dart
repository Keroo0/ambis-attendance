import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../features/attendance/data/services/geofence_settings_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../features/grades/presentation/providers/grades_provider.dart';
import '../../features/history/presentation/providers/history_provider.dart';
import '../../features/leave_request/presentation/providers/leave_provider.dart';
import '../../features/notifications/presentation/providers/notification_preferences_provider.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../features/parent/presentation/providers/parent_provider.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';
import 'notification_service.dart';

const _realtimeTables = [
  'attendance',
  'grades',
  'leave_requests',
  'notifications',
  'notification_preferences',
  'users',
  'students',
  'settings',
];

enum RealtimeRefreshTarget {
  authUser,
  dashboardAttendance,
  attendanceHistory,
  studentGrades,
  profileGrades,
  profileStudent,
  leaveRequests,
  notifications,
  notificationPreferences,
  parentChildInfo,
  parentAttendance,
  parentGrades,
  attendanceSettings,
  checkInReminder,
}

List<RealtimeRefreshTarget> realtimeRefreshTargetsForTable(String table) {
  switch (table) {
    case 'attendance':
      return const [
        RealtimeRefreshTarget.dashboardAttendance,
        RealtimeRefreshTarget.attendanceHistory,
        RealtimeRefreshTarget.parentAttendance,
        RealtimeRefreshTarget.checkInReminder,
      ];
    case 'grades':
      return const [
        RealtimeRefreshTarget.studentGrades,
        RealtimeRefreshTarget.parentGrades,
        RealtimeRefreshTarget.profileGrades,
      ];
    case 'leave_requests':
      return const [
        RealtimeRefreshTarget.leaveRequests,
        RealtimeRefreshTarget.attendanceHistory,
        RealtimeRefreshTarget.parentAttendance,
      ];
    case 'notifications':
      return const [RealtimeRefreshTarget.notifications];
    case 'notification_preferences':
      return const [RealtimeRefreshTarget.notificationPreferences];
    case 'users':
      return const [
        RealtimeRefreshTarget.authUser,
        RealtimeRefreshTarget.profileStudent,
        RealtimeRefreshTarget.parentChildInfo,
      ];
    case 'students':
      return const [
        RealtimeRefreshTarget.profileStudent,
        RealtimeRefreshTarget.parentChildInfo,
      ];
    case 'settings':
      return const [
        RealtimeRefreshTarget.attendanceSettings,
        RealtimeRefreshTarget.checkInReminder,
      ];
    default:
      return const [];
  }
}

class RealtimeRefreshCoordinator {
  RealtimeRefreshCoordinator(this._ref, {sb.SupabaseClient? client})
      : _client = client ?? sb.Supabase.instance.client;

  final Ref _ref;
  final sb.SupabaseClient _client;

  sb.RealtimeChannel? _channel;
  String? _subscribedUserId;

  void start() {}

  void stop() {
    _removeChannel();
  }

  void setUser(UserEntity? user) {
    if (user == null) {
      _subscribedUserId = null;
      _removeChannel();
      return;
    }

    if (_subscribedUserId == user.id && _channel != null) return;

    _subscribedUserId = user.id;
    _removeChannel();

    var channel = _client.channel('ambis-realtime-refresh:${user.id}');
    for (final table in _realtimeTables) {
      channel = channel.onPostgresChanges(
        event: sb.PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (_) => _handleTableChange(table, user),
      );
    }
    _channel = channel.subscribe();
  }

  void _removeChannel() {
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      unawaited(_client.removeChannel(channel));
    }
  }

  void _handleTableChange(String table, UserEntity user) {
    final targets = realtimeRefreshTargetsForTable(table);
    for (final target in targets) {
      _invalidate(target, user);
    }
  }

  void _invalidate(RealtimeRefreshTarget target, UserEntity user) {
    switch (target) {
      case RealtimeRefreshTarget.authUser:
        unawaited(_ref.read(authProvider.notifier).refreshUser());
        break;
      case RealtimeRefreshTarget.dashboardAttendance:
        _ref
          ..invalidate(dashboardTodayAttendanceProvider)
          ..invalidate(dashboardRecentAttendanceProvider);
        break;
      case RealtimeRefreshTarget.attendanceHistory:
        _ref.invalidate(historyProvider);
        break;
      case RealtimeRefreshTarget.studentGrades:
        _ref.invalidate(gradesProvider);
        break;
      case RealtimeRefreshTarget.profileGrades:
        _ref.invalidate(profileGradeSummaryProvider);
        break;
      case RealtimeRefreshTarget.profileStudent:
        _ref
          ..invalidate(profileStudentProvider)
          ..invalidate(profileHomeroomTeacherProvider);
        break;
      case RealtimeRefreshTarget.leaveRequests:
        _ref.invalidate(leaveProvider);
        break;
      case RealtimeRefreshTarget.notifications:
        _ref.invalidate(notificationsProvider);
        break;
      case RealtimeRefreshTarget.notificationPreferences:
        _ref.invalidate(notificationPreferencesProvider);
        break;
      case RealtimeRefreshTarget.parentChildInfo:
        _ref.invalidate(childInfoProvider);
        break;
      case RealtimeRefreshTarget.parentAttendance:
        _ref
          ..invalidate(childAttendanceThisMonthProvider)
          ..invalidate(childTodayAttendanceProvider)
          ..invalidate(childLeaveRequestsProvider)
          ..invalidate(childAttendanceProvider);
        break;
      case RealtimeRefreshTarget.parentGrades:
        _ref
          ..invalidate(childGradesSummaryProvider)
          ..invalidate(childGradesProvider)
          ..invalidate(childOverallAverageProvider);
        break;
      case RealtimeRefreshTarget.attendanceSettings:
        _ref.invalidate(geofenceSettingsProvider);
        break;
      case RealtimeRefreshTarget.checkInReminder:
        if (user.role == 'siswa') {
          unawaited(
            _ref
                .read(notificationServiceProvider)
                .startCheckInReminder(studentId: user.id),
          );
        }
        break;
    }
  }
}

final realtimeRefreshCoordinatorProvider =
    Provider<RealtimeRefreshCoordinator>((ref) {
  final coordinator = RealtimeRefreshCoordinator(ref);
  ref.listen<AsyncValue<UserEntity?>>(
    authProvider,
    (_, next) => coordinator.setUser(next.valueOrNull),
    fireImmediately: true,
  );
  ref.onDispose(coordinator.stop);
  return coordinator;
});
