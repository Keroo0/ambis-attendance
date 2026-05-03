import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String dateOnly(DateTime dt) =>
      DateFormat('yyyy-MM-dd').format(dt);

  static String timeOnly(DateTime dt) =>
      DateFormat('HH:mm:ss').format(dt);

  static String iso(DateTime dt) => dt.toIso8601String();

  /// Parses a `HH:mm` string into a Duration since midnight.
  static Duration parseHHmm(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return Duration(hours: h, minutes: m);
  }

  /// Returns the current time as a Duration since midnight.
  static Duration nowAsDuration() {
    final now = DateTime.now();
    return Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
    );
  }

  /// True if [now] falls inside the [start, end] HH:mm window (inclusive).
  static bool isWithinWindow(Duration now, String start, String end) {
    final s = parseHHmm(start);
    final e = parseHHmm(end);
    return now >= s && now <= e;
  }
}
