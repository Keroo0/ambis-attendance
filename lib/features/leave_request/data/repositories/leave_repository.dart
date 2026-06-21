import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

import '../../../../core/exceptions/app_exception.dart';

const Uuid _uuid = Uuid();
const _kBucketName = 'leave-documents';
const int _kMaxBytes = 1024 * 1024; // 1 MB

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class LeaveRepository {
  LeaveRepository(this._supabase);

  final sb.SupabaseClient _supabase;

  /// Maps UI dropdown value to DB enum ('sakit' or 'izin').
  static String mapType(String uiType) => uiType == 'Sakit' ? 'sakit' : 'izin';

  /// Throws [LeaveException] if [file] is not jpg/jpeg.
  static void validateExtension(File file) {
    final path = file.path.toLowerCase();
    if (!path.endsWith('.jpg') && !path.endsWith('.jpeg')) {
      throw const LeaveException('Format file harus JPG.');
    }
  }

  /// Submits a leave request directly to Supabase.
  /// Returns the inserted row as [Map<String, dynamic>].
  Future<Map<String, dynamic>> submitLeave({
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
    await _supabase.storage.from(_kBucketName).uploadBinary(
          storagePath,
          compressed,
          fileOptions: const sb.FileOptions(contentType: 'image/jpeg'),
        );

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await _supabase
        .from('leave_requests')
        .insert({
          'id': id,
          'student_id': studentId,
          'type': mapType(uiType),
          'reason': reason.isEmpty ? null : reason,
          'date_from': _formatDate(dateFrom),
          'date_to': _formatDate(dateTo),
          'attachment_url': storagePath,
          'status': 'pending',
          'created_at': now,
          'updated_at': now,
        })
        .select()
        .single();

    return result;
  }

  /// Returns all leave requests for [studentId] ordered by created_at desc.
  Future<List<Map<String, dynamic>>> getLeavesByStudent(
      String studentId) async {
    final rows = await _supabase
        .from('leave_requests')
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>();
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
  return LeaveRepository(sb.Supabase.instance.client);
});
