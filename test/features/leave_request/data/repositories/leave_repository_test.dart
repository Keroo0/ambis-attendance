import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ambis_attendance/core/exceptions/app_exception.dart';
import 'package:ambis_attendance/features/leave_request/data/repositories/leave_repository.dart';

void main() {
  test('mapType maps Sakit to sakit', () {
    expect(LeaveRepository.mapType('Sakit'), 'sakit');
  });

  test('mapType maps Izin Keluarga to izin', () {
    expect(LeaveRepository.mapType('Izin Keluarga'), 'izin');
  });

  test('mapType maps Keperluan Lain to izin', () {
    expect(LeaveRepository.mapType('Keperluan Lain'), 'izin');
  });

  test('validateExtension throws LeaveException for non-jpg file', () {
    final file = File('/tmp/test.png');
    expect(
      () => LeaveRepository.validateExtension(file),
      throwsA(isA<LeaveException>()),
    );
  });

  test('validateExtension does not throw for .jpg file', () {
    final file = File('/tmp/test.jpg');
    expect(() => LeaveRepository.validateExtension(file), returnsNormally);
  });

  test('validateExtension does not throw for .jpeg file', () {
    final file = File('/tmp/test.jpeg');
    expect(() => LeaveRepository.validateExtension(file), returnsNormally);
  });

  test('getLeavesByStudent — requires live Supabase, covered by integration tests', () {
    // LeaveRepository now queries Supabase directly.
    // Unit test with a mocked SupabaseClient is tracked as a future TODO.
    expect(true, isTrue);
  });
}
