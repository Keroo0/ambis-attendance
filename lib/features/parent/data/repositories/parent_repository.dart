import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

// ── Student info ──────────────────────────────────────────────────────────────

class ChildStudentInfo {
  const ChildStudentInfo({
    required this.studentId,
    required this.fullname,
    required this.nisn,
    required this.className,
  });

  final String studentId;
  final String fullname;
  final String nisn;
  final String className;

  String get initials {
    final parts =
        fullname.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── Grades ────────────────────────────────────────────────────────────────────

class ChildGradeRow {
  const ChildGradeRow({
    required this.subject,
    required this.utsScore,
  });

  final String subject;
  final double utsScore;
}

// ── Attendance ────────────────────────────────────────────────────────────────

enum ParentAttendanceStatus { hadir, terlambat, izin, sakit, alfa }

class ParentAttendanceDay {
  const ParentAttendanceDay({
    required this.date,
    required this.status,
    this.timeIn,
    this.timeOut,
    this.leaveType,
  });

  /// ISO date string: 'YYYY-MM-DD'
  final String date;
  final ParentAttendanceStatus status;
  final String? timeIn;
  final String? timeOut;

  /// 'izin' | 'sakit' when status is [ParentAttendanceStatus.izin] or [ParentAttendanceStatus.sakit]
  final String? leaveType;
}

class ParentAttendanceSummary {
  const ParentAttendanceSummary({
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
    required this.records,
  });

  /// Hadir includes terlambat (late but present).
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;
  final List<ParentAttendanceDay> records;

  static const empty = ParentAttendanceSummary(
      hadir: 0, izin: 0, sakit: 0, alfa: 0, records: []);
}

// ── Repository ────────────────────────────────────────────────────────────────

class ParentRepository {
  ParentRepository(this._client);

  final sb.SupabaseClient _client;

  // ── Child info ──────────────────────────────────────────────────────────────

  /// Returns the child student linked to [parentUserId] via students.parent_id.
  /// Returns null if no child is found. Throws on network/DB error.
  Future<ChildStudentInfo?> getChildInfo(String parentUserId) async {
    final List<dynamic> rows = await _client
        .from('students')
        .select('id, nisn, class')
        .eq('parent_id', parentUserId)
        .limit(1);

    if (rows.isEmpty) return null;

    final student = rows.first as Map<String, dynamic>;
    final studentId = student['id'] as String;

    final Map<String, dynamic> userRow = await _client
        .from('users')
        .select('fullname')
        .eq('id', studentId)
        .single();

    return ChildStudentInfo(
      studentId: studentId,
      fullname: userRow['fullname'] as String? ?? '-',
      nisn: student['nisn'] as String? ?? '-',
      className: student['class'] as String? ?? '-',
    );
  }

  // ── Grades ──────────────────────────────────────────────────────────────────

  /// Returns top UTS grades for [studentId] from Supabase, latest semester.
  /// Throws on network/DB error.
  Future<List<ChildGradeRow>> getChildGradesSummary(String studentId) async {
    final List<dynamic> rows = await _client
        .from('grades')
        .select('subject, score')
        .eq('student_id', studentId)
        .eq('type', 'UTS')
        .order('subject')
        .limit(5);

    return rows
        .map((r) => ChildGradeRow(
              subject: r['subject'] as String,
              utsScore: (r['score'] as num).toDouble(),
            ))
        .toList();
  }

  /// Returns the overall average (UTS + UAS) for [studentId].
  /// Throws on network/DB error.
  Future<double?> getChildOverallAverage(String studentId) async {
    final List<dynamic> rows = await _client
        .from('grades')
        .select('score')
        .eq('student_id', studentId);

    if (rows.isEmpty) return null;
    final total =
        rows.fold<double>(0, (sum, r) => sum + (r['score'] as num).toDouble());
    return total / rows.length;
  }

  // ── Attendance ──────────────────────────────────────────────────────────────

  /// Returns count of attended days for [studentId] in the given month.
  Future<int> getChildAttendanceCountThisMonth(
      String studentId, int year, int month) async {
    final mm = month.toString().padLeft(2, '0');
    final List<dynamic> rows = await _client
        .from('attendance')
        .select('id')
        .eq('student_id', studentId)
        .like('date', '$year-$mm-%');
    return rows.length;
  }

  /// Fetches full attendance data for [studentId] in the given month,
  /// merging approved leave requests to determine daily status.
  Future<ParentAttendanceSummary> getChildAttendanceForMonth(
      String studentId, int year, int month) async {
    final mm = month.toString().padLeft(2, '0');
    final lastDay = _daysInMonth(year, month);
    final monthStart = '$year-$mm-01';
    final monthEnd = '$year-$mm-${lastDay.toString().padLeft(2, '0')}';

    final List<dynamic> attendanceRows = await _client
        .from('attendance')
        .select('date, time_in, time_out')
        .eq('student_id', studentId)
        .gte('date', monthStart)
        .lte('date', monthEnd)
        .order('date');

    final List<dynamic> leaveRows = await _client
        .from('leave_requests')
        .select('type, date_from, date_to')
        .eq('student_id', studentId)
        .eq('status', 'approved')
        .lte('date_from', monthEnd)
        .gte('date_to', monthStart);

    final attendanceByDate = <String, Map<String, dynamic>>{
      for (final r in attendanceRows.cast<Map<String, dynamic>>())
        r['date'] as String: r,
    };

    String? leaveTypeForDate(String dateStr) {
      for (final l in leaveRows.cast<Map<String, dynamic>>()) {
        final from = l['date_from'] as String?;
        final to = l['date_to'] as String?;
        if (from == null || to == null) continue;
        if (dateStr.compareTo(from) >= 0 && dateStr.compareTo(to) <= 0) {
          return l['type'] as String?;
        }
      }
      return null;
    }

    final today = DateTime.now();
    final records = <ParentAttendanceDay>[];
    int hadir = 0, izin = 0, sakit = 0, alfa = 0;

    for (int day = 1; day <= lastDay; day++) {
      final date = DateTime(year, month, day);
      if (date.isAfter(today)) continue;
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }

      final dateStr = '$year-$mm-${day.toString().padLeft(2, '0')}';
      final row = attendanceByDate[dateStr];

      ParentAttendanceStatus status;
      String? timeIn;
      String? timeOut;
      String? leaveType;

      if (row != null) {
        timeIn = row['time_in'] as String?;
        timeOut = row['time_out'] as String?;
        if (timeIn != null && timeIn.compareTo('07:30') > 0) {
          status = ParentAttendanceStatus.terlambat;
        } else {
          status = ParentAttendanceStatus.hadir;
        }
        hadir++;
      } else {
        final lt = leaveTypeForDate(dateStr);
        if (lt == 'sakit') {
          status = ParentAttendanceStatus.sakit;
          leaveType = 'sakit';
          sakit++;
        } else if (lt == 'izin') {
          status = ParentAttendanceStatus.izin;
          leaveType = 'izin';
          izin++;
        } else {
          status = ParentAttendanceStatus.alfa;
          alfa++;
        }
      }

      records.add(ParentAttendanceDay(
        date: dateStr,
        status: status,
        timeIn: timeIn,
        timeOut: timeOut,
        leaveType: leaveType,
      ));
    }

    return ParentAttendanceSummary(
      hadir: hadir,
      izin: izin,
      sakit: sakit,
      alfa: alfa,
      records: records,
    );
  }

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;
}

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentRepository(sb.Supabase.instance.client);
});
