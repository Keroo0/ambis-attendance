import 'package:drift/drift.dart';

@DataClassName('FaceEmbeddingEntity')
class FaceEmbeddings extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text().unique()();
  // Float32 array (192 * 4 = 768 bytes) packed as Uint8List.
  BlobColumn get embedding => blob()();
  IntColumn get enrollmentDate => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get syncedToSupabase =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
