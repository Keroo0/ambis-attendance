import 'package:drift/drift.dart';

import 'students.dart';

@DataClassName('FaceEmbeddingEntity')
class FaceEmbeddings extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text().unique().references(Students, #id)();
  // Float32 array (128 * 4 = 512 bytes) packed as Uint8List.
  BlobColumn get embedding => blob()();
  IntColumn get enrollmentDate => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
