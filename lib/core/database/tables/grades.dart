import 'package:drift/drift.dart';

import 'students.dart';
import 'users.dart';

@DataClassName('GradeEntity')
class Grades extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text().references(Students, #id)();
  TextColumn get subject => text()();
  TextColumn get type =>
      text().check(type.isIn(const ['UTS', 'UAS', 'tugas']))();
  RealColumn get score =>
      real().check(score.isBetweenValues(0, 100))();
  IntColumn get semester =>
      integer().nullable().check(semester.isIn(const [1, 2]))();
  IntColumn get year => integer().nullable()();
  TextColumn get inputtedBy => text().nullable().references(Users, #id)();
  IntColumn get syncedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
