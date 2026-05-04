import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';

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
  AttendanceHistoryRepository(this._db);

  final AppDatabase _db;

  Future<List<AttendanceDay>> getMonthRecords(
    String studentId,
    int year,
    int month,
  ) async {
    final mm = month.toString().padLeft(2, '0');
    final prefix = '$year-$mm-';

    // Fetch attendance rows for the month.
    final attendanceRows = await (_db.select(_db.attendance)
          ..where((a) => a.studentId.equals(studentId))
          ..where((a) => a.date.like('$prefix%')))
        .get();

    // Fetch approved leave requests that overlap this month.
    final lastDay = DateUtils.getDaysInMonth(year, month);
    final monthStart = '$year-$mm-01';
    final monthEnd = '$year-$mm-${lastDay.toString().padLeft(2, '0')}';

    final leaveRows = await (_db.select(_db.leaveRequests)
          ..where((l) => l.studentId.equals(studentId))
          ..where((l) => l.status.equals('approved'))
          ..where((l) => l.dateFrom.isSmallerOrEqualValue(monthEnd))
          ..where((l) => l.dateTo.isBiggerOrEqualValue(monthStart)))
        .get();

    // Build lookup maps.
    final attendanceByDate = {
      for (final r in attendanceRows) r.date: r,
    };

    bool isApprovedLeave(String dateStr) {
      for (final leave in leaveRows) {
        final from = leave.dateFrom;
        final to = leave.dateTo;
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
      // Skip future dates and weekends (Saturday=6, Sunday=7).
      if (date.isAfter(today)) { continue; }
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) { continue; }

      final dateStr = '$year-$mm-${day.toString().padLeft(2, '0')}';
      final attendanceRow = attendanceByDate[dateStr];

      AttendanceStatus status;
      String? checkInTime;
      String? checkOutTime;

      if (attendanceRow != null) {
        checkInTime = attendanceRow.timeIn;
        checkOutTime = attendanceRow.timeOut;
        // Compare time strings lexicographically — works for HH:mm format.
        if (checkInTime != null && checkInTime.compareTo('07:30') <= 0) {
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
  return AttendanceHistoryRepository(ref.watch(appDatabaseProvider));
});
