import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ParentAttendanceHistoryScreen extends StatefulWidget {
  const ParentAttendanceHistoryScreen({super.key});

  @override
  State<ParentAttendanceHistoryScreen> createState() => _State();
}

class _State extends State<ParentAttendanceHistoryScreen> {
  int _selectedMonth = 0;

  static const _months = [
    'Oktober 2023',
    'September 2023',
    'Agustus 2023',
    'Juli 2023',
  ];

  static const _records = [
    _Record(
      dayLabel: 'Senin, 16 Okt',
      sessionType: 'Reguler',
      status: 'hadir',
      checkIn: '06:45',
      checkOut: '15:30',
    ),
    _Record(
      dayLabel: 'Jumat, 13 Okt',
      sessionType: 'Jumat Berkah',
      status: 'hadir',
      checkIn: '06:50',
      checkOut: '11:30',
    ),
    _Record(
      dayLabel: 'Kamis, 12 Okt',
      sessionType: 'Reguler',
      status: 'izin',
      reason: 'Acara Keluarga - Disetujui',
      hasAttachment: true,
    ),
    _Record(
      dayLabel: 'Rabu, 11 Okt',
      sessionType: 'Reguler',
      status: 'hadir',
      checkIn: '07:05',
      checkOut: '15:30',
      isLate: true,
    ),
    _Record(
      dayLabel: 'Selasa, 10 Okt',
      sessionType: 'Reguler',
      status: 'hadir',
      checkIn: '06:40',
      checkOut: '15:35',
    ),
  ];

  // Summary stats per month (index-matched to _months)
  static const _stats = [
    (hadir: 18, izin: 1, sakit: 0, alpa: 0),
    (hadir: 20, izin: 0, sakit: 1, alpa: 0),
    (hadir: 21, izin: 1, sakit: 0, alpa: 0),
    (hadir: 19, izin: 0, sakit: 0, alpa: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final stat = _stats[_selectedMonth];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: const Color(0xFF002B5B),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF002B5B),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE0E3E5)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _StudentSummaryCard(stat: stat),
          const SizedBox(height: 16),
          _MonthFilterBar(
            months: _months,
            selectedIndex: _selectedMonth,
            onSelect: (i) => setState(() => _selectedMonth = i),
          ),
          const SizedBox(height: 16),
          const _AttendanceListCard(records: _records),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Student Summary Card ──────────────────────────────────────────────────────

class _StudentSummaryCard extends StatelessWidget {
  const _StudentSummaryCard({required this.stat});

  final ({int hadir, int izin, int sakit, int alpa}) stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6D0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x05000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: const Color(0xFF006A63)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFD6E3FF),
                          child: Text(
                            'AF',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002B5B),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ahmad Fauzi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF002B5B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Kelas XII MIPA 1 • 19201004',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF43474F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE0E3E5)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBadge(
                            value: '${stat.hadir}',
                            label: 'HADIR',
                            color: const Color(0xFF006A63),
                          ),
                        ),
                        Expanded(
                          child: _StatBadge(
                            value: '${stat.izin}',
                            label: 'IZIN',
                            color: const Color(0xFFFABD00),
                          ),
                        ),
                        Expanded(
                          child: _StatBadge(
                            value: '${stat.sakit}',
                            label: 'SAKIT',
                            color: const Color(0xFF201600),
                          ),
                        ),
                        Expanded(
                          child: _StatBadge(
                            value: '${stat.alpa}',
                            label: 'ALPA',
                            color: const Color(0xFFBA1A1A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Color(0xFF43474F),
          ),
        ),
      ],
    );
  }
}

// ── Month Filter Bar ──────────────────────────────────────────────────────────

class _MonthFilterBar extends StatelessWidget {
  const _MonthFilterBar({
    required this.months,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> months;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: months.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          final selected = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < months.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF002B5B)
                      : const Color(0xFFECEEF0),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: selected
                      ? [
                          const BoxShadow(
                              color: Color(0x20002B5B),
                              blurRadius: 6,
                              offset: Offset(0, 2))
                        ]
                      : null,
                ),
                child: Text(
                  m,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        selected ? Colors.white : const Color(0xFF43474F),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Attendance List Card ──────────────────────────────────────────────────────

class _AttendanceListCard extends StatelessWidget {
  const _AttendanceListCard({required this.records});

  final List<_Record> records;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E5)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x05000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'TANGGAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0xFF43474F),
                    ),
                  ),
                ),
                Text(
                  'WAKTU & STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Color(0xFF43474F),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E3E5)),
          ...records.asMap().entries.map((e) {
            return _RecordRow(
              record: e.value,
              isLast: e.key == records.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record, required this.isLast});

  final _Record record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Color? bgTint;
    if (record.status == 'izin') {
      bgTint = const Color(0xFFFABD00).withValues(alpha: 0.06);
    } else if (record.status == 'alpa') {
      bgTint = const Color(0xFFBA1A1A).withValues(alpha: 0.04);
    }

    return Container(
      color: bgTint,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.dayLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF191C1E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.sessionType,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF43474F)),
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: record.status),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: (record.status == 'hadir')
                ? _TimeRow(
                    checkIn: record.checkIn!,
                    checkOut: record.checkOut!,
                    isLate: record.isLate,
                  )
                : _ReasonRow(
                    reason: record.reason ?? '',
                    hasAttachment: record.hasAttachment,
                  ),
          ),
          if (!isLast)
            const Divider(height: 1, color: Color(0xFFE6E8EA)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color textColor;
    final String label;
    final IconData icon;

    switch (status) {
      case 'izin':
        bg = const Color(0xFFFABD00).withValues(alpha: 0.2);
        border = const Color(0xFFFABD00).withValues(alpha: 0.5);
        textColor = const Color(0xFF5B4300);
        label = 'Izin';
        icon = Icons.info_rounded;
      case 'sakit':
        bg = const Color(0xFF1E66F5).withValues(alpha: 0.1);
        border = const Color(0xFF1E66F5).withValues(alpha: 0.3);
        textColor = const Color(0xFF1E66F5);
        label = 'Sakit';
        icon = Icons.healing_rounded;
      case 'alpa':
        bg = const Color(0xFFBA1A1A).withValues(alpha: 0.1);
        border = const Color(0xFFBA1A1A).withValues(alpha: 0.3);
        textColor = const Color(0xFFBA1A1A);
        label = 'Alpa';
        icon = Icons.cancel_rounded;
      default: // hadir
        bg = const Color(0xFF006A63).withValues(alpha: 0.1);
        border = const Color(0xFF006A63).withValues(alpha: 0.3);
        textColor = const Color(0xFF006A63);
        label = 'Hadir';
        icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.checkIn,
    required this.checkOut,
    required this.isLate,
  });

  final String checkIn;
  final String checkOut;
  final bool isLate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.login_rounded,
            size: 14,
            color: isLate ? const Color(0xFF5B4300) : const Color(0xFF43474F),
          ),
          const SizedBox(width: 4),
          Text(
            checkIn,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isLate ? const Color(0xFF5B4300) : const Color(0xFF191C1E),
            ),
          ),
          if (isLate) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDF9E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Terlambat',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF261A00),
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
          Container(
              width: 1, height: 14, color: const Color(0xFFC4C6D0)),
          const SizedBox(width: 12),
          const Icon(Icons.logout_rounded,
              size: 14, color: Color(0xFF43474F)),
          const SizedBox(width: 4),
          Text(
            checkOut,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF191C1E),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({required this.reason, required this.hasAttachment});

  final String reason;
  final bool hasAttachment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              reason,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF43474F),
              ),
            ),
          ),
          if (hasAttachment) ...[
            const SizedBox(width: 8),
            const Icon(Icons.attach_file_rounded,
                size: 14, color: Color(0xFF747780)),
          ],
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _Record {
  const _Record({
    required this.dayLabel,
    required this.sessionType,
    required this.status,
    this.isLate = false,
    this.checkIn,
    this.checkOut,
    this.reason,
    this.hasAttachment = false,
  });

  final String dayLabel;
  final String sessionType;
  final String status;
  final bool isLate;
  final String? checkIn;
  final String? checkOut;
  final String? reason;
  final bool hasAttachment;
}
