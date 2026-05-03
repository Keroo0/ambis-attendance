import 'package:drift/drift.dart';

import 'attendance.dart';
import 'students.dart';
import 'users.dart';

@DataClassName('LeaveRequestEntity')
class LeaveRequests extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text().references(Students, #id)();
  TextColumn get attendanceId =>
      text().nullable().references(Attendance, #id)();
  TextColumn get type => text().check(type.isIn(const ['izin', 'sakit']))();
  TextColumn get reason => text().nullable()();
  TextColumn get attachmentUrl => text().nullable()();
  TextColumn get attachmentLocalPath => text().nullable()();
  TextColumn get status => text().check(
        status.isIn(const ['pending', 'approved', 'rejected']),
      )();
  TextColumn get rejectedReason => text().nullable()();
  TextColumn get reviewedBy => text().nullable().references(Users, #id)();
  IntColumn get reviewedAt => integer().nullable()();
  TextColumn get dateFrom => text().nullable()(); // YYYY-MM-DD
  TextColumn get dateTo => text().nullable()(); // YYYY-MM-DD
  IntColumn get syncedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
