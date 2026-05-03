import 'package:drift/drift.dart';

import 'students.dart';

@DataClassName('AttendanceEntity')
class Attendance extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text().references(Students, #id)();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get timeIn => text().nullable()(); // HH:MM:SS
  TextColumn get timeOut => text().nullable()(); // HH:MM:SS
  TextColumn get status => text().check(status.isIn(
        const ['present', 'absent', 'late', 'leave', 'sick'],
      ))();
  BoolColumn get isWithinGeofence =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get livenessVerified =>
      boolean().withDefault(const Constant(false))();
  RealColumn get faceMatchScore => real().nullable()();
  RealColumn get locationLat => real().nullable()();
  RealColumn get locationLng => real().nullable()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get syncedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {studentId, date},
      ];
}
