import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import '../../shared/utils/date_formatter.dart';

const int _kCheckInReminderId = 1001;
const int _kReminderLeadMinutes = 15;
const String _kChannelId = 'ambis_reminder';
const String _kChannelName = 'Pengingat Absen';
const String _kChannelDesc = 'Notifikasi pengingat absen sebelum waktu habis';

class NotificationService {
  NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Inisialisasi plugin. Dipanggil dari main() setelah WidgetsFlutterBinding.
  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _onTap,
    );
  }

  /// Minta izin notifikasi dari OS. Aman dipanggil berulang kali.
  Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.requestNotificationsPermission();
    } else if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Jadwalkan notifikasi harian 15 menit sebelum deadline check-in.
  /// Jika [studentId] diberikan dan siswa sudah absen hari ini, tidak dijadwalkan.
  Future<void> scheduleCheckInReminder({String? studentId}) async {
    await cancelReminder();

    if (studentId != null) {
      try {
        final today = DateFormatter.dateOnly(DateTime.now());
        final rows = await Supabase.instance.client
            .from('attendance')
            .select('time_in')
            .eq('student_id', studentId)
            .eq('date', today)
            .limit(1);
        final list = rows as List;
        if (list.isNotEmpty &&
            (list.first as Map<String, dynamic>)['time_in'] != null) {
          debugPrint('[Notification] Sudah absen hari ini — reminder dilewati.');
          return;
        }
      } catch (_) {
        // Non-fatal — proceed with scheduling.
      }
    }

    final timeInEnd = await _readTimeInEnd();
    final endDuration = DateFormatter.parseHHmm(timeInEnd);
    final reminderDuration =
        endDuration - const Duration(minutes: _kReminderLeadMinutes);

    final localTz = await _resolveLocalTimeZone();
    final location = tz.getLocation(localTz);
    final now = tz.TZDateTime.now(location);

    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      reminderDuration.inHours,
      reminderDuration.inMinutes.remainder(60),
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Pengingat Absen',
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _plugin.zonedSchedule(
        _kCheckInReminderId,
        'Jangan Lupa Absen!',
        'Jangan lupa absen sebelum terlambat! '
            'Waktu absen masuk berakhir pukul $timeInEnd.',
        scheduled,
        details,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[Notification] Reminder dijadwalkan: $scheduled');
    } catch (e) {
      debugPrint('[Notification] Exact alarm gagal ($e), pakai inexact.');
      await _plugin.zonedSchedule(
        _kCheckInReminderId,
        'Jangan Lupa Absen!',
        'Jangan lupa absen sebelum terlambat! '
            'Waktu absen masuk berakhir pukul $timeInEnd.',
        scheduled,
        details,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Batalkan reminder yang sedang terjadwal.
  Future<void> cancelReminder() async {
    await _plugin.cancel(_kCheckInReminderId);
  }

  void _onTap(NotificationResponse response) {
    debugPrint('[Notification] Di-tap: ${response.id}');
  }

  Future<String> _readTimeInEnd() async {
    try {
      final rows = await Supabase.instance.client
          .from('settings')
          .select('key, value')
          .eq('key', 'time_in_end')
          .limit(1);
      final list = rows as List;
      if (list.isNotEmpty) {
        return (list.first as Map<String, dynamic>)['value'] as String? ??
            AppConstants.defaultTimeInEnd;
      }
    } catch (_) {}
    return AppConstants.defaultTimeInEnd;
  }

  Future<String> _resolveLocalTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      return info.identifier;
    } catch (_) {
      return 'Asia/Jakarta';
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
