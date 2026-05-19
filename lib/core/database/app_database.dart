import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/face_embeddings.dart';
import '_db_connection_native.dart' if (dart.library.html) '_db_connection_web.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [FaceEmbeddings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppDatabaseConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(faceEmbeddings, faceEmbeddings.syncedToSupabase);
          }
        },
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
