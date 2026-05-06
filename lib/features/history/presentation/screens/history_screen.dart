import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/attendance_history_repository.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _displayMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return _displayMonth.year < now.year ||
        (_displayMonth.year == now.year && _displayMonth.month < now.month);
  }

  void _prevMonth() => setState(() {
        _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
        _selectedDate = null;
      });

  void _nextMonth() {
    if (!_canGoNext) return;
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(historyProvider((_displayMonth.year, _displayMonth.month)));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF191C1E),
        elevation: 0,
        title: const Text(
          'Riwayat Kehadiran',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191C1E),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF006A63),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajukan Izin'),
        onPressed: () => context.push('/leave'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Gagal memuat riwayat: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFBA1A1A)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(
                    historyProvider((_displayMonth.year, _displayMonth.month)),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (records) {
          final recordMap = {
            for (final r in records)
              DateTime(r.date.year, r.date.month, r.date.day): r,
          };
          final hadir =
              records.where((r) => r.status == AttendanceStatus.hadir).length;
          final terlambat = records
              .where((r) => r.status == AttendanceStatus.terlambat)
              .length;
          final izin =
              records.where((r) => r.status == AttendanceStatus.izin).length;
          final alfa =
              records.where((r) => r.status == AttendanceStatus.alfa).length;
          final selectedRecord =
              _selectedDate != null ? recordMap[_selectedDate] : null;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _CalendarCard(
                displayMonth: _displayMonth,
                recordMap: recordMap,
                selectedDate: _selectedDate,
                canGoNext: _canGoNext,
                onDateTap: (d) => setState(() => _selectedDate = d),
                onPrevMonth: _prevMonth,
                onNextMonth: _nextMonth,
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                  hadir: hadir,
                  terlambat: terlambat,
                  izin: izin,
                  alfa: alfa),
              if (_selectedDate != null) ...[
                const SizedBox(height: 12),
                _DayDetailCard(date: _selectedDate!, record: selectedRecord),
              ],
              const SizedBox(height: 12),
              const _LegendRow(),
              const SizedBox(height: 12),
              _RecentList(records: records.reversed.toList()),
            ],
          );
        },
      ),
    );
  }
}

// ── Calendar ─────────────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.displayMonth,
    required this.recordMap,
    required this.selectedDate,
    required this.canGoNext,
    required this.onDateTap,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime displayMonth;
  final Map<DateTime, AttendanceDay> recordMap;
  final DateTime? selectedDate;
  final bool canGoNext;
  final ValueChanged<DateTime> onDateTap;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(displayMonth.year, displayMonth.month);
    final offset =
        DateTime(displayMonth.year, displayMonth.month, 1).weekday - 1;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF43474F),
                onPressed: onPrevMonth,
              ),
              Text(
                '${_monthNames[displayMonth.month - 1]} ${displayMonth.year}',
                style: const TextStyle(
                  color: Color(0xFF191C1E),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: canGoNext
                        ? const Color(0xFF43474F)
                        : const Color(0xFFE0E3E5)),
                onPressed: canGoNext ? onNextMonth : null,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: _dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            color: Color(0xFF747780),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 2,
            ),
            itemCount: offset + daysInMonth,
            itemBuilder: (_, index) {
              if (index < offset) return const SizedBox.shrink();
              final day = index - offset + 1;
              final date = DateTime(displayMonth.year, displayMonth.month, day);
              final record = recordMap[date];
              final isSelected = selectedDate != null &&
                  selectedDate!.year == date.year &&
                  selectedDate!.month == date.month &&
                  selectedDate!.day == date.day;
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              return _CalendarCell(
                day: day,
                record: record,
                isSelected: isSelected,
                isToday: isToday,
                onTap: () => onDateTap(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.record,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final AttendanceDay? record;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  Color get _statusColor {
    if (record == null) return Colors.transparent;
    switch (record!.status) {
      case AttendanceStatus.hadir:
        return const Color(0xFF16A34A);
      case AttendanceStatus.terlambat:
        return const Color(0xFFEA580C);
      case AttendanceStatus.izin:
        return const Color(0xFF006A63);
      case AttendanceStatus.alfa:
        return const Color(0xFFBA1A1A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? const Color(0xFF006A63)
              : record != null
                  ? _statusColor.withValues(alpha: 0.15)
                  : Colors.transparent,
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF006A63), width: 1.5)
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? const Color(0xFF006A63)
                          : const Color(0xFF191C1E),
                  fontSize: 11,
                  fontWeight:
                      isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              if (record != null && !isSelected)
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.hadir,
    required this.terlambat,
    required this.izin,
    required this.alfa,
  });

  final int hadir;
  final int terlambat;
  final int izin;
  final int alfa;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryChip(label: 'Hadir', value: hadir, color: const Color(0xFF16A34A)),
        const SizedBox(width: 8),
        _SummaryChip(label: 'Terlambat', value: terlambat, color: const Color(0xFFEA580C)),
        const SizedBox(width: 8),
        _SummaryChip(label: 'Izin', value: izin, color: const Color(0xFF006A63)),
        const SizedBox(width: 8),
        _SummaryChip(label: 'Alfa', value: alfa, color: const Color(0xFFBA1A1A)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF43474F), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Day detail ────────────────────────────────────────────────────────────────

class _DayDetailCard extends StatelessWidget {
  const _DayDetailCard({required this.date, required this.record});

  final DateTime date;
  final AttendanceDay? record;

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

    String statusLabel;
    Color statusColor;
    String detail;

    if (record == null) {
      statusLabel = 'Tidak ada data';
      statusColor = const Color(0xFF747780);
      detail = 'Hari libur atau data belum tersedia.';
    } else {
      switch (record!.status) {
        case AttendanceStatus.hadir:
          statusLabel = 'Hadir';
          statusColor = const Color(0xFF16A34A);
          detail = 'Masuk pukul ${record!.checkInTime ?? '-'}';
        case AttendanceStatus.terlambat:
          statusLabel = 'Terlambat';
          statusColor = const Color(0xFFEA580C);
          detail = 'Masuk pukul ${record!.checkInTime ?? '-'}';
        case AttendanceStatus.izin:
          statusLabel = 'Izin';
          statusColor = const Color(0xFF006A63);
          detail = 'Izin resmi disetujui';
        case AttendanceStatus.alfa:
          statusLabel = 'Alfa';
          statusColor = const Color(0xFFBA1A1A);
          detail = 'Tidak hadir tanpa keterangan';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: const TextStyle(
                        color: Color(0xFF43474F), fontSize: 12)),
                const SizedBox(height: 2),
                Text(detail,
                    style: const TextStyle(
                        color: Color(0xFF191C1E), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: Color(0xFF16A34A), label: 'Hadir'),
        SizedBox(width: 12),
        _LegendDot(color: Color(0xFFEA580C), label: 'Terlambat'),
        SizedBox(width: 12),
        _LegendDot(color: Color(0xFF006A63), label: 'Izin'),
        SizedBox(width: 12),
        _LegendDot(color: Color(0xFFBA1A1A), label: 'Alfa'),
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

// ── Recent list ───────────────────────────────────────────────────────────────

class _RecentList extends StatelessWidget {
  const _RecentList({required this.records});

  final List<AttendanceDay> records;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text('Belum ada data bulan ini.',
              style: TextStyle(color: Color(0xFF747780))),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Bulan Ini',
          style: TextStyle(
              color: Color(0xFF43474F),
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...records.map((r) {
          Color color;
          String label;
          switch (r.status) {
            case AttendanceStatus.hadir:
              color = const Color(0xFF16A34A);
              label = 'Hadir';
            case AttendanceStatus.terlambat:
              color = const Color(0xFFEA580C);
              label = 'Terlambat';
            case AttendanceStatus.izin:
              color = const Color(0xFF006A63);
              label = 'Izin';
            case AttendanceStatus.alfa:
              color = const Color(0xFFBA1A1A);
              label = 'Alfa';
          }
          final dateStr =
              '${r.date.day} ${_monthNames[r.date.month - 1]}';
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFC4C6D0).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 10),
                Text(dateStr,
                    style: const TextStyle(
                        color: Color(0xFF43474F), fontSize: 12)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r.checkInTime != null ? 'Masuk ${r.checkInTime}' : label,
                    style: const TextStyle(
                        color: Color(0xFF191C1E), fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
