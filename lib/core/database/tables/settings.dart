import 'package:drift/drift.dart';

@DataClassName('SettingEntity')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get type => text().check(
        type.isIn(const ['string', 'int', 'bool', 'double']),
      )();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}
