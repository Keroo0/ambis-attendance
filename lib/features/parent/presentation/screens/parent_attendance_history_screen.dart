import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/parent_provider.dart';
import '../../data/repositories/parent_repository.dart';

class ParentAttendanceHistoryScreen extends ConsumerStatefulWidget {
  const ParentAttendanceHistoryScreen({super.key});

  @override
  ConsumerState<ParentAttendanceHistoryScreen> createState() => _State();
}

class _State extends ConsumerState<ParentAttendanceHistoryScreen> {
  int _selectedMonth = 0;

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static List<String> _buildMonths() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final d = DateTime(now.year, now.month - i);
      return '${_monthNames[d.month - 1]} ${d.year}';
    });
  }

  static List<(int, int)> _buildMonthDates() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final d = DateTime(now.year, now.month - i);
      return (d.year, d.month);
    });
  }

  final _months = _buildMonths();
  final _monthDates = _buildMonthDates();

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childInfoProvider);
    final (year, month) = _monthDates[_selectedMonth];
    final attendanceAsync = ref.watch(childAttendanceProvider((year, month)));

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
      body: childAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Color(0xFFC4C6D0)),
              const SizedBox(height: 12),
              const Text('Gagal memuat data.',
                  style: TextStyle(color: Color(0xFF43474F))),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(childInfoProvider),
                child: const Text('Coba Lagi',
                    style: TextStyle(color: Color(0xFF006A63))),
              ),
            ],
          ),
        ),
        data: (child) {
          final summary = attendanceAsync.valueOrNull;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _StudentSummaryCard(child: child, summary: summary),
              const SizedBox(height: 16),
              _MonthFilterBar(
                months: _months,
                selectedIndex: _selectedMonth,
                onSelect: (i) => setState(() => _selectedMonth = i),
              ),
              const SizedBox(height: 16),
              attendanceAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _ErrorCard(
                  onRetry: () => ref.invalidate(
                    childAttendanceProvider((year, month)),
                  ),
                ),
                data: (att) => att.records.isEmpty
                    ? const _EmptyAttendanceState()
                    : _AttendanceList(records: att.records),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Student Summary Card ──────────────────────────────────────────────────────

class _StudentSummaryCard extends StatelessWidget {
  const _StudentSummaryCard({required this.child, required this.summary});

  final ChildStudentInfo? child;
  final ParentAttendanceSummary? summary;

  @override
  Widget build(BuildContext context) {
    final name = child?.fullname ?? '-';
    final className = child?.className ?? '-';
    final nisn = child?.nisn ?? '-';
    final initials = child?.initials ?? '?';

    String stat(int? v) => v != null ? '$v' : '-';

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6D0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x05000000),
              blurRadius: 16,
              offset: Offset(0, 4)),
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFFD6E3FF),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002B5B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF002B5B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kelas $className • $nisn',
                                style: const TextStyle(
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
                              value: stat(summary?.hadir),
                              label: 'HADIR',
                              color: const Color(0xFF006A63)),
                        ),
                        Expanded(
                          child: _StatBadge(
                              value: stat(summary?.izin),
                              label: 'IZIN',
                              color: const Color(0xFFFABD00)),
                        ),
                        Expanded(
                          child: _StatBadge(
                              value: stat(summary?.sakit),
                              label: 'SAKIT',
                              color: const Color(0xFF0078D4)),
                        ),
                        Expanded(
                          child: _StatBadge(
                              value: stat(summary?.alfa),
                              label: 'ALPA',
                              color: const Color(0xFFBA1A1A)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF002B5B)
                      : const Color(0xFFECEEF0),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: selected
                      ? const [
                          BoxShadow(
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyAttendanceState extends StatelessWidget {
  const _EmptyAttendanceState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 48, color: Color(0xFFC4C6D0)),
          SizedBox(height: 12),
          Text(
            'Belum ada data absensi.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF43474F),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Data kehadiran akan muncul setelah siswa\nmelakukan absensi di bulan ini.',
            style: TextStyle(fontSize: 12, color: Color(0xFF747780)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Error card ────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 40, color: Color(0xFFC4C6D0)),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat data absensi.',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF43474F)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi',
                style: TextStyle(color: Color(0xFF006A63))),
          ),
        ],
      ),
    );
  }
}

// ── Attendance list ───────────────────────────────────────────────────────────

class _AttendanceList extends StatelessWidget {
  const _AttendanceList({required this.records});
  final List<ParentAttendanceDay> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LegendRow(),
        const SizedBox(height: 12),
        ...records.reversed.map((r) => _AttendanceDayTile(day: r)),
      ],
    );
  }
}

class _AttendanceDayTile extends StatelessWidget {
  const _AttendanceDayTile({required this.day});
  final ParentAttendanceDay day;

  static const _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const _dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(day.date);
    final dateStr =
        '${_dayNames[date.weekday - 1]}, ${date.day} ${_monthShort[date.month - 1]}';

    final Color color;
    final String label;
    final String detail;

    switch (day.status) {
      case ParentAttendanceStatus.hadir:
        color = const Color(0xFF16A34A);
        label = 'Hadir';
        detail = day.timeIn != null
            ? 'Masuk ${_formatTime(day.timeIn!)}'
            : 'Hadir';
      case ParentAttendanceStatus.terlambat:
        color = const Color(0xFFEA580C);
        label = 'Terlambat';
        detail = day.timeIn != null
            ? 'Masuk ${_formatTime(day.timeIn!)}'
            : 'Terlambat';
      case ParentAttendanceStatus.izin:
        color = const Color(0xFFFABD00);
        label = 'Izin';
        detail = 'Izin resmi disetujui';
      case ParentAttendanceStatus.sakit:
        color = const Color(0xFF0078D4);
        label = 'Sakit';
        detail = 'Sakit — surat disetujui';
      case ParentAttendanceStatus.alfa:
        color = const Color(0xFFBA1A1A);
        label = 'Alpa';
        detail = 'Tidak hadir tanpa keterangan';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: Color(0xFF43474F)),
            ),
          ),
          Expanded(
            child: Text(
              detail,
              style:
                  const TextStyle(fontSize: 13, color: Color(0xFF191C1E)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String t) {
    // Convert '07:15:00' → '07.15'
    final parts = t.split(':');
    if (parts.length < 2) return t;
    return '${parts[0]}.${parts[1]}';
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _LegendDot(color: Color(0xFF16A34A), label: 'Hadir'),
        _LegendDot(color: Color(0xFFEA580C), label: 'Terlambat'),
        _LegendDot(color: Color(0xFFFABD00), label: 'Izin'),
        _LegendDot(color: Color(0xFF0078D4), label: 'Sakit'),
        _LegendDot(color: Color(0xFFBA1A1A), label: 'Alpa'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF43474F), fontSize: 11)),
      ],
    );
  }
}
