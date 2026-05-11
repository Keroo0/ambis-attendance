import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/exceptions/app_exception.dart';

const Uuid _uuid = Uuid();
const _kBucketName = 'leave-documents';
const int _kMaxBytes = 1024 * 1024; // 1 MB

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class LeaveRepository {
  LeaveRepository(this._db);

  final AppDatabase _db;

  /// Maps UI dropdown value to DB enum ('sakit' or 'izin').
  static String mapType(String uiType) =>
      uiType == 'Sakit' ? 'sakit' : 'izin';

  /// Throws [LeaveException] if [file] is not jpg/jpeg.
  static void validateExtension(File file) {
    final path = file.path.toLowerCase();
    if (!path.endsWith('.jpg') && !path.endsWith('.jpeg')) {
      throw const LeaveException('Format file harus JPG.');
    }
  }

  Future<LeaveRequestEntity> submitLeave({
    required String studentId,
    required String uiType,
    required String reason,
    required DateTime dateFrom,
    required DateTime dateTo,
    required File imageFile,
  }) async {
    validateExtension(imageFile);

    final compressed = await _compress(imageFile);

    final storagePath = '$studentId/${_uuid.v4()}.jpg';
    await sb.Supabase.instance.client.storage
        .from(_kBucketName)
        .uploadBinary(
          storagePath,
          compressed,
          fileOptions: const sb.FileOptions(contentType: 'image/jpeg'),
        );

    final attachmentUrl = sb.Supabase.instance.client.storage
        .from(_kBucketName)
        .getPublicUrl(storagePath);

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await sb.Supabase.instance.client.from('leave_requests').insert({
      'id': id,
      'student_id': studentId,
      'type': mapType(uiType),
      'reason': reason.isEmpty ? null : reason,
      'date_from': _formatDate(dateFrom),
      'date_to': _formatDate(dateTo),
      'attachment_url': attachmentUrl,
      'status': 'pending',
      'created_at': now,
      'updated_at': now,
    });

    await _db.into(_db.leaveRequests).insert(
      LeaveRequestsCompanion.insert(
        id: id,
        studentId: studentId,
        type: mapType(uiType),
        reason: drift.Value(reason),
        dateFrom: drift.Value(_formatDate(dateFrom)),
        dateTo: drift.Value(_formatDate(dateTo)),
        attachmentUrl: drift.Value(attachmentUrl),
        attachmentLocalPath: drift.Value(imageFile.path),
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      ),
    );

    return (_db.select(_db.leaveRequests)
          ..where((l) => l.id.equals(id)))
        .getSingle();
  }

  Future<List<LeaveRequestEntity>> getLeavesByStudent(String studentId) {
    return (_db.select(_db.leaveRequests)
          ..where((l) => l.studentId.equals(studentId))
          ..orderBy([(l) => drift.OrderingTerm.desc(l.createdAt)]))
        .get();
  }

  Future<Uint8List> _compress(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1080,
      minHeight: 1080,
      quality: 85,
      format: CompressFormat.jpeg,
    );
    if (result == null) throw const LeaveException('Gagal mengompresi gambar.');

    if (result.length > _kMaxBytes) {
      result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 1080,
        minHeight: 1080,
        quality: 60,
        format: CompressFormat.jpeg,
      );
      if (result == null || result.length > _kMaxBytes) {
        throw const LeaveException(
            'Ukuran file terlalu besar setelah kompresi. Pilih foto lain.');
      }
    }

    return result;
  }
}

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository(ref.watch(appDatabaseProvider));
});
