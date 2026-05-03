enum NotificationType { attendance, leave, system }

class DummyNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final NotificationType type;

  const DummyNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.type,
  });
}

final kDummyNotifications = <DummyNotification>[
  DummyNotification(
    id: '5',
    title: 'Absensi Berhasil Dicatat',
    body: 'Absen masuk hari ini berhasil tercatat pukul 07:12.',
    time: DateTime(2026, 5, 1, 7, 12),
    isRead: false,
    type: NotificationType.attendance,
  ),
  DummyNotification(
    id: '4',
    title: 'Reminder: Absen Pulang',
    body: 'Jangan lupa absen pulang hari ini sebelum pukul 16:00.',
    time: DateTime(2026, 4, 30, 13, 45),
    isRead: false,
    type: NotificationType.system,
  ),
  DummyNotification(
    id: '3',
    title: 'Nilai UTS Tersedia',
    body: 'Nilai UTS Semester 1 telah diinput oleh admin. Cek di halaman Nilai.',
    time: DateTime(2026, 4, 15, 14, 0),
    isRead: true,
    type: NotificationType.system,
  ),
  DummyNotification(
    id: '2',
    title: 'Pengajuan Izin Disetujui',
    body: 'Izin sakit tanggal 14–15 April 2026 telah disetujui oleh wali kelas.',
    time: DateTime(2026, 4, 14, 9, 0),
    isRead: true,
    type: NotificationType.leave,
  ),
  DummyNotification(
    id: '1',
    title: 'Pengajuan Izin Ditolak',
    body: 'Izin tanggal 20 Maret 2026 ditolak. Alasan: Tidak ada surat keterangan dari orangtua.',
    time: DateTime(2026, 3, 21, 10, 30),
    isRead: true,
    type: NotificationType.leave,
  ),
];

int get kUnreadNotificationCount =>
    kDummyNotifications.where((n) => !n.isRead).length;
