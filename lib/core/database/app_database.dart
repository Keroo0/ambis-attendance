import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'tables/attendance.dart';
import 'tables/attendance_queue.dart';
import 'tables/audit_log.dart';
import 'tables/face_embeddings.dart';
import 'tables/grades.dart';
import 'tables/leave_requests.dart';
import 'tables/settings.dart';
import 'tables/students.dart';
import 'tables/users.dart';
import '_db_connection_native.dart' if (dart.library.html) '_db_connection_web.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  Students,
  FaceEmbeddings,
  Attendance,
  AttendanceQueue,
  Grades,
  LeaveRequests,
  AuditLog,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppDatabaseConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaultSettings();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(
                faceEmbeddings, faceEmbeddings.syncedToSupabase);
          }
        },
      );

  Future<void> _seedDefaultSettings() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final defaults = <(String, String, String)>[
      (
        'face_recognition_threshold',
        AppConstants.defaultFaceThreshold.toString(),
        'double'
      ),
      (
        'geofence_radius',
        AppConstants.geofenceRadiusMeters.toStringAsFixed(0),
        'int'
      ),
      ('time_in_start', AppConstants.defaultTimeInStart, 'string'),
      ('time_in_end', AppConstants.defaultTimeInEnd, 'string'),
      ('time_out_start', AppConstants.defaultTimeOutStart, 'string'),
      ('time_out_end', AppConstants.defaultTimeOutEnd, 'string'),
      ('demo_mode', 'false', 'bool'),
    ];

    for (final (key, value, type) in defaults) {
      await into(settings).insert(
        SettingsCompanion.insert(
          key: key,
          value: value,
          type: type,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
