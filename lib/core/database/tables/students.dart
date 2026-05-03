import 'package:drift/drift.dart';

import 'users.dart';

@DataClassName('StudentEntity')
class Students extends Table {
  TextColumn get id => text().references(Users, #id)();
  TextColumn get nisn => text().unique()();
  // Dart `class` is a reserved word — keep Dart name `className`,
  // but persist the SQL column as `class` (matches DATABASE_SCHEMA.md).
  TextColumn get className => text().named('class')();
  TextColumn get parentId => text().nullable().references(Users, #id)();
  TextColumn get dateOfBirth => text().nullable()(); // YYYY-MM-DD
  TextColumn get gender =>
      text().nullable().check(gender.isIn(const ['M', 'F']))();
  TextColumn get address => text().nullable()();
  TextColumn get phoneParent => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
