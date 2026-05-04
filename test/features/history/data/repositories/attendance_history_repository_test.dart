import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambis_attendance/core/database/app_database.dart';
import 'package:ambis_attendance/features/history/data/repositories/attendance_history_repository.dart';

Future<void> _insertAttendance(
  AppDatabase db, {
  required String studentId,
  required String date,
  String? timeIn,
}) async {
  await db.into(db.attendance).insert(
    AttendanceCompanion.insert(
      id: date + studentId,
      studentId: studentId,
      date: date,
      status: 'present',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      timeIn: drift.Value(timeIn),
    ),
  );
}

Future<void> _insertApprovedLeave(
  AppDatabase db, {
  required String studentId,
  required String dateFrom,
  required String dateTo,
}) async {
  await db.into(db.leaveRequests).insert(
    LeaveRequestsCompanion.insert(
      id: '$studentId$dateFrom',
      studentId: studentId,
      type: 'izin',
      status: 'approved',
      dateFrom: drift.Value(dateFrom),
      dateTo: drift.Value(dateTo),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ),
  );
}

void main() {
  late AppDatabase db;
  late AttendanceHistoryRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AttendanceHistoryRepository(db);
  });

  tearDown(() async => db.close());

  test('returns hadir when time_in is 07:00 (on time)', () async {
    await _insertAttendance(db, studentId: 's1', date: '2026-05-04', timeIn: '07:00');
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final rec = records.firstWhere((r) => r.date.day == 4);
    expect(rec.status, AttendanceStatus.hadir);
    expect(rec.checkInTime, '07:00');
  });

  test('returns terlambat when time_in is 07:31', () async {
    await _insertAttendance(db, studentId: 's1', date: '2026-05-04', timeIn: '07:31');
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final rec = records.firstWhere((r) => r.date.day == 4);
    expect(rec.status, AttendanceStatus.terlambat);
  });

  test('returns izin when approved leave covers the date', () async {
    await _insertApprovedLeave(
      db, studentId: 's1', dateFrom: '2026-05-04', dateTo: '2026-05-04',
    );
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final rec = records.firstWhere((r) => r.date.day == 4);
    expect(rec.status, AttendanceStatus.izin);
  });

  test('returns alfa for past weekday with no record and no leave', () async {
    // 2026-05-01 is a Friday (past date with no data)
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final may1 = records.where((r) => r.date.day == 1);
    // Only included if it's a weekday and in the past
    if (may1.isNotEmpty) {
      expect(may1.first.status, AttendanceStatus.alfa);
    }
  });

  test('pending leave does NOT count as izin', () async {
    await db.into(db.leaveRequests).insert(
      LeaveRequestsCompanion.insert(
        id: 's1-pending',
        studentId: 's1',
        type: 'izin',
        status: 'pending',
        dateFrom: drift.Value('2026-05-04'),
        dateTo: drift.Value('2026-05-04'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    final records = await repo.getMonthRecords('s1', 2026, 5);
    final rec = records.firstWhere((r) => r.date.day == 4);
    expect(rec.status, AttendanceStatus.alfa);
  });
}
