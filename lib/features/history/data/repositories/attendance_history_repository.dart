import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AttendanceStatus { hadir, terlambat, izin, alfa }

class AttendanceDay {
  const AttendanceDay({
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
  });

  final DateTime date;
  final AttendanceStatus status;
  final String? checkInTime;
  final String? checkOutTime;
}

class AttendanceHistoryRepository {
  AttendanceHistoryRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<AttendanceDay>> getMonthRecords(
    String studentId,
    int year,
    int month,
  ) async {
    final mm = month.toString().padLeft(2, '0');
    final prefix = '$year-$mm-';

    // Fetch attendance rows for the month from Supabase.
    final attendanceResponse = await _supabase
        .from('attendance')
        .select()
        .eq('student_id', studentId)
        .like('date', '$prefix%');
    final attendanceRows = (attendanceResponse as List)
        .cast<Map<String, dynamic>>();

    // Fetch approved leave requests overlapping this month.
    final lastDay = DateUtils.getDaysInMonth(year, month);
    final monthStart = '$year-$mm-01';
    final monthEnd = '$year-$mm-${lastDay.toString().padLeft(2, '0')}';

    final leaveResponse = await _supabase
        .from('leave_requests')
        .select('date_from, date_to')
        .eq('student_id', studentId)
        .eq('status', 'approved')
        .lte('date_from', monthEnd)
        .gte('date_to', monthStart);
    final leaveRows = (leaveResponse as List).cast<Map<String, dynamic>>();

    // Build lookup map for attendance rows.
    final attendanceByDate = <String, Map<String, dynamic>>{
      for (final r in attendanceRows)
        (r['date'] as String? ?? ''): r,
    };

    bool isApprovedLeave(String dateStr) {
      for (final leave in leaveRows) {
        final from = leave['date_from'] as String?;
        final to = leave['date_to'] as String?;
        if (from != null &&
            to != null &&
            dateStr.compareTo(from) >= 0 &&
            dateStr.compareTo(to) <= 0) {
          return true;
        }
      }
      return false;
    }

    final today = DateTime.now();
    final result = <AttendanceDay>[];

    for (int day = 1; day <= lastDay; day++) {
      final date = DateTime(year, month, day);
      // Skip future dates and weekends.
      if (date.isAfter(today)) continue;
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }

      final dateStr = '$year-$mm-${day.toString().padLeft(2, '0')}';
      final attendanceRow = attendanceByDate[dateStr];

      AttendanceStatus status;
      String? checkInTime;
      String? checkOutTime;

      if (attendanceRow != null) {
        checkInTime = attendanceRow['time_in'] as String?;
        checkOutTime = attendanceRow['time_out'] as String?;
        // Compare time strings lexicographically — works for HH:mm format.
        if (checkInTime == null || checkInTime.compareTo('07:30') <= 0) {
          status = AttendanceStatus.hadir;
        } else {
          status = AttendanceStatus.terlambat;
        }
      } else if (isApprovedLeave(dateStr)) {
        status = AttendanceStatus.izin;
      } else {
        status = AttendanceStatus.alfa;
      }

      result.add(AttendanceDay(
        date: date,
        status: status,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
      ));
    }

    return result;
  }
}

final attendanceHistoryRepositoryProvider =
    Provider<AttendanceHistoryRepository>((ref) {
  return AttendanceHistoryRepository(Supabase.instance.client);
});
