enum LeaveStatus { pending, approved, rejected }

class DummyLeaveRequest {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String reason;
  final LeaveStatus status;
  final String? rejectionReason;

  const DummyLeaveRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
    required this.status,
    this.rejectionReason,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;
}

final kDummyLeaves = <DummyLeaveRequest>[
  DummyLeaveRequest(
    id: '3',
    startDate: DateTime(2026, 4, 14),
    endDate: DateTime(2026, 4, 15),
    type: 'Sakit',
    reason: 'Demam tinggi, sudah ke dokter.',
    status: LeaveStatus.approved,
  ),
  DummyLeaveRequest(
    id: '2',
    startDate: DateTime(2026, 3, 20),
    endDate: DateTime(2026, 3, 20),
    type: 'Izin Keluarga',
    reason: 'Ada acara keluarga mendadak.',
    status: LeaveStatus.rejected,
    rejectionReason: 'Tidak disertai surat keterangan dari orangtua.',
  ),
  DummyLeaveRequest(
    id: '1',
    startDate: DateTime(2026, 2, 10),
    endDate: DateTime(2026, 2, 11),
    type: 'Sakit',
    reason: 'Flu dan batuk berat.',
    status: LeaveStatus.approved,
  ),
];
