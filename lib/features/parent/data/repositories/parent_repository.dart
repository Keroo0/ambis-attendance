import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class ChildStudentInfo {
  const ChildStudentInfo({
    required this.studentId,
    required this.fullname,
    required this.nisn,
    required this.className,
  });

  final String studentId;
  final String fullname;
  final String nisn;
  final String className;

  String get initials {
    final parts =
        fullname.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class ChildGradeRow {
  const ChildGradeRow({
    required this.subject,
    required this.utsScore,
  });

  final String subject;
  final double utsScore;
}

class ParentRepository {
  ParentRepository(this._client);

  final sb.SupabaseClient _client;

  /// Returns the child student linked to [parentUserId] via students.parent_id.
  /// Returns null if no child is found.
  Future<ChildStudentInfo?> getChildInfo(String parentUserId) async {
    final List<dynamic> rows;
    try {
      rows = await _client
          .from('students')
          .select('id, nisn, class')
          .eq('parent_id', parentUserId)
          .limit(1);
    } catch (_) {
      return null;
    }

    if (rows.isEmpty) return null;

    final student = rows.first as Map<String, dynamic>;
    final studentId = student['id'] as String;

    // Fetch fullname from users table using the student id
    final Map<String, dynamic> userRow;
    try {
      userRow = await _client
          .from('users')
          .select('fullname')
          .eq('id', studentId)
          .single();
    } catch (_) {
      return null;
    }

    return ChildStudentInfo(
      studentId: studentId,
      fullname: userRow['fullname'] as String? ?? '-',
      nisn: student['nisn'] as String? ?? '-',
      className: student['class'] as String? ?? '-',
    );
  }

  /// Returns top UTS grades for [studentId] from Supabase, latest semester.
  Future<List<ChildGradeRow>> getChildGradesSummary(String studentId) async {
    final List<dynamic> rows;
    try {
      rows = await _client
          .from('grades')
          .select('subject, score')
          .eq('student_id', studentId)
          .eq('type', 'UTS')
          .order('subject')
          .limit(5);
    } catch (_) {
      return [];
    }

    return rows
        .map((r) => ChildGradeRow(
              subject: r['subject'] as String,
              utsScore: (r['score'] as num).toDouble(),
            ))
        .toList();
  }

  /// Returns the overall average (UTS + UAS + tugas) for [studentId].
  Future<double?> getChildOverallAverage(String studentId) async {
    final List<dynamic> rows;
    try {
      rows = await _client
          .from('grades')
          .select('score')
          .eq('student_id', studentId);
    } catch (_) {
      return null;
    }

    if (rows.isEmpty) return null;
    final total =
        rows.fold<double>(0, (sum, r) => sum + (r['score'] as num).toDouble());
    return total / rows.length;
  }
}

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentRepository(sb.Supabase.instance.client);
});
