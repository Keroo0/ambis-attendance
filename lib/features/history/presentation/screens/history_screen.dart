import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/widgets/gradient_background.dart';
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
      appBar: AppBar(title: const Text('Riwayat Kehadiran')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajukan Izin'),
        onPressed: () => context.push('/leave'),
      ),
      body: GradientBackground(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gagal memuat riwayat: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: Spacing.sm),
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
              padding: const EdgeInsets.fromLTRB(
                  Spacing.md, Spacing.md, Spacing.md, 100),
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
                const SizedBox(height: Spacing.sm),
                _SummaryRow(
                    hadir: hadir,
                    terlambat: terlambat,
                    izin: izin,
                    alfa: alfa),
                if (_selectedDate != null) ...[
                  const SizedBox(height: Spacing.sm),
                  _DayDetailCard(date: _selectedDate!, record: selectedRecord),
                ],
                const SizedBox(height: Spacing.sm),
                const _LegendRow(),
                const SizedBox(height: Spacing.sm),
                _RecentList(records: records.reversed.toList()),
              ],
            );
          },
        ),
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
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: AppColors.textSecondary,
                onPressed: onPrevMonth,
              ),
              Text(
                '${_monthNames[displayMonth.month - 1]} ${displayMonth.year}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: canGoNext
                        ? AppColors.textSecondary
                        : AppColors.surfaceAlt),
                onPressed: canGoNext ? onNextMonth : null,
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: _dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            color: AppColors.textHint,
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
        return AppColors.success;
      case AttendanceStatus.terlambat:
        return AppColors.warning;
      case AttendanceStatus.izin:
        return AppColors.secondary;
      case AttendanceStatus.alfa:
        return AppColors.error;
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
              ? AppColors.accent
              : record != null
                  ? _statusColor.withAlpha(51)
                  : Colors.transparent,
          border: isToday && !isSelected
              ? Border.all(color: AppColors.accent, width: 1.5)
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
                      ? AppColors.background
                      : isToday
                          ? AppColors.accent
                          : AppColors.textPrimary,
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
        _SummaryChip(label: 'Hadir', value: hadir, color: AppColors.success),
        const SizedBox(width: Spacing.xs),
        _SummaryChip(
            label: 'Terlambat', value: terlambat, color: AppColors.warning),
        const SizedBox(width: Spacing.xs),
        _SummaryChip(label: 'Izin', value: izin, color: AppColors.secondary),
        const SizedBox(width: Spacing.xs),
        _SummaryChip(label: 'Alfa', value: alfa, color: AppColors.error),
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
          color: color.withAlpha(31),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(77), width: 1),
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
                  color: AppColors.textSecondary, fontSize: 10),
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
      statusColor = AppColors.textHint;
      detail = 'Hari libur atau data belum tersedia.';
    } else {
      switch (record!.status) {
        case AttendanceStatus.hadir:
          statusLabel = 'Hadir';
          statusColor = AppColors.success;
          detail = 'Masuk pukul ${record!.checkInTime ?? '-'}';
        case AttendanceStatus.terlambat:
          statusLabel = 'Terlambat';
          statusColor = AppColors.warning;
          detail = 'Masuk pukul ${record!.checkInTime ?? '-'}';
        case AttendanceStatus.izin:
          statusLabel = 'Izin';
          statusColor = AppColors.secondary;
          detail = 'Izin resmi disetujui';
        case AttendanceStatus.alfa:
          statusLabel = 'Alfa';
          statusColor = AppColors.error;
          detail = 'Tidak hadir tanpa keterangan';
      }
    }

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(31),
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
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(detail,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(31),
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
        _LegendDot(color: AppColors.success, label: 'Hadir'),
        SizedBox(width: 12),
        _LegendDot(color: AppColors.warning, label: 'Terlambat'),
        SizedBox(width: 12),
        _LegendDot(color: AppColors.secondary, label: 'Izin'),
        SizedBox(width: 12),
        _LegendDot(color: AppColors.error, label: 'Alfa'),
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
                color: AppColors.textSecondary, fontSize: 11)),
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
              style: TextStyle(color: AppColors.textHint)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Bulan Ini',
          style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.xs),
        ...records.map((r) {
          Color color;
          String label;
          switch (r.status) {
            case AttendanceStatus.hadir:
              color = AppColors.success;
              label = 'Hadir';
            case AttendanceStatus.terlambat:
              color = AppColors.warning;
              label = 'Terlambat';
            case AttendanceStatus.izin:
              color = AppColors.secondary;
              label = 'Izin';
            case AttendanceStatus.alfa:
              color = AppColors.error;
              label = 'Alfa';
          }
          final dateStr =
              '${r.date.day} ${_monthNames[r.date.month - 1]}';
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: Spacing.sm),
                Text(dateStr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    r.checkInTime != null ? 'Masuk ${r.checkInTime}' : label,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withAlpha(31),
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
