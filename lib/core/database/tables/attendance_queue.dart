import 'package:drift/drift.dart';

import 'attendance.dart';
import 'students.dart';

@DataClassName('AttendanceQueueEntity')
class AttendanceQueue extends Table {
  TextColumn get id => text()();
  TextColumn get attendanceId => text().references(Attendance, #id)();
  TextColumn get studentId => text().references(Students, #id)();
  TextColumn get action =>
      text().check(action.isIn(const ['create', 'update', 'delete']))();
  TextColumn get payload => text()(); // JSON-encoded attendance row
  TextColumn get status => text().check(
        status.isIn(const ['pending', 'synced', 'failed']),
      )();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
