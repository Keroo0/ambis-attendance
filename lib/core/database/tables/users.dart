import 'package:drift/drift.dart';

@DataClassName('UserEntity')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get nisn => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get role =>
      text().check(role.isIn(const ['siswa', 'admin', 'ortu']))();
  TextColumn get fullname => text()();
  TextColumn get email => text().nullable().unique()();
  TextColumn get phone => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
