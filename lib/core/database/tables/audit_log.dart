import 'package:drift/drift.dart';

import 'users.dart';

@DataClassName('AuditLogEntity')
class AuditLog extends Table {
  TextColumn get id => text()();
  TextColumn get adminId => text().references(Users, #id)();
  TextColumn get action => text()();
  TextColumn get entityType => text().check(
        entityType.isIn(const ['leave', 'grade', 'student', 'attendance']),
      )();
  TextColumn get entityId => text()();
  TextColumn get oldValue => text().nullable()(); // JSON
  TextColumn get newValue => text().nullable()(); // JSON
  TextColumn get ipAddress => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
