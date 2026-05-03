enum AttendanceStatus { hadir, terlambat, izin, alfa }

class DummyAttendanceRecord {
  final DateTime date;
  final AttendanceStatus status;
  final String? checkInTime;

  DummyAttendanceRecord({
    required this.date,
    required this.status,
    this.checkInTime,
  });
}

// April 2026: April 1 = Wednesday (weekday=3)
// School days only (Mon–Fri). April 14–15 = izin (sakit).
final kDummyAttendanceRecords = <DummyAttendanceRecord>[
  // April 2026
  DummyAttendanceRecord(date: DateTime(2026, 4, 1), status: AttendanceStatus.hadir, checkInTime: '07:10'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 2), status: AttendanceStatus.hadir, checkInTime: '07:05'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 3), status: AttendanceStatus.hadir, checkInTime: '07:20'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 6), status: AttendanceStatus.hadir, checkInTime: '07:15'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 7), status: AttendanceStatus.hadir, checkInTime: '07:08'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 8), status: AttendanceStatus.terlambat, checkInTime: '07:38'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 9), status: AttendanceStatus.hadir, checkInTime: '07:12'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 10), status: AttendanceStatus.hadir, checkInTime: '07:18'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 13), status: AttendanceStatus.hadir, checkInTime: '07:22'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 14), status: AttendanceStatus.izin),
  DummyAttendanceRecord(date: DateTime(2026, 4, 15), status: AttendanceStatus.izin),
  DummyAttendanceRecord(date: DateTime(2026, 4, 16), status: AttendanceStatus.hadir, checkInTime: '07:10'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 17), status: AttendanceStatus.hadir, checkInTime: '07:14'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 20), status: AttendanceStatus.hadir, checkInTime: '07:09'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 21), status: AttendanceStatus.hadir, checkInTime: '07:16'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 22), status: AttendanceStatus.hadir, checkInTime: '07:11'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 23), status: AttendanceStatus.terlambat, checkInTime: '07:42'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 24), status: AttendanceStatus.hadir, checkInTime: '07:07'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 27), status: AttendanceStatus.alfa),
  DummyAttendanceRecord(date: DateTime(2026, 4, 28), status: AttendanceStatus.hadir, checkInTime: '07:13'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 29), status: AttendanceStatus.hadir, checkInTime: '07:08'),
  DummyAttendanceRecord(date: DateTime(2026, 4, 30), status: AttendanceStatus.hadir, checkInTime: '07:06'),

  // May 2026 (May 1 = Friday, May 2 = Saturday = weekend)
  DummyAttendanceRecord(date: DateTime(2026, 5, 1), status: AttendanceStatus.hadir, checkInTime: '07:12'),
];
