import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../../shared/utils/date_formatter.dart';

const int _kCheckInReminderId = 1001;
const int _kReminderLeadMinutes = 15;
const String _kChannelId = 'ambis_reminder';
const String _kChannelName = 'Pengingat Absen';
const String _kChannelDesc = 'Notifikasi pengingat absen sebelum waktu habis';

class NotificationService {
  NotificationService(this._db);

  final AppDatabase _db;
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
      final today = DateFormatter.dateOnly(DateTime.now());
      final existing = await (_db.select(_db.attendance)
            ..where((a) => a.studentId.equals(studentId))
            ..where((a) => a.date.equals(today)))
          .getSingleOrNull();
      if (existing?.timeIn != null) {
        debugPrint('[Notification] Sudah absen hari ini — reminder dilewati.');
        return;
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
      // Fallback jika SCHEDULE_EXACT_ALARM tidak diizinkan (MIUI/Samsung agresif)
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
    final rows = await _db.select(_db.settings).get();
    final map = {for (final r in rows) r.key: r.value};
    return map['time_in_end'] ?? AppConstants.defaultTimeInEnd;
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
  return NotificationService(ref.watch(appDatabaseProvider));
});
