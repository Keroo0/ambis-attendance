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

  // Generate last 6 months dynamically
  static List<String> _buildMonths() {
    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    final now = DateTime.now();
    return List.generate(6, (i) {
      final d = DateTime(now.year, now.month - i);
      return '${monthNames[d.month - 1]} ${d.year}';
    });
  }

  final _months = _buildMonths();

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childInfoProvider);

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
        data: (child) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _StudentSummaryCard(child: child),
            const SizedBox(height: 16),
            _MonthFilterBar(
              months: _months,
              selectedIndex: _selectedMonth,
              onSelect: (i) => setState(() => _selectedMonth = i),
            ),
            const SizedBox(height: 16),
            const _EmptyAttendanceCard(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Student Summary Card ──────────────────────────────────────────────────────

class _StudentSummaryCard extends StatelessWidget {
  const _StudentSummaryCard({required this.child});

  final ChildStudentInfo? child;

  @override
  Widget build(BuildContext context) {
    final name = child?.fullname ?? '-';
    final className = child?.className ?? '-';
    final nisn = child?.nisn ?? '-';
    final initials = child?.initials ?? '?';

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
                    const Row(
                      children: [
                        Expanded(
                          child: _StatBadge(
                              value: '0', label: 'HADIR',
                              color: Color(0xFF006A63)),
                        ),
                        Expanded(
                          child: _StatBadge(
                              value: '0', label: 'IZIN',
                              color: Color(0xFFFABD00)),
                        ),
                        Expanded(
                          child: _StatBadge(
                              value: '0', label: 'SAKIT',
                              color: Color(0xFF201600)),
                        ),
                        Expanded(
                          child: _StatBadge(
                              value: '0', label: 'ALPA',
                              color: Color(0xFFBA1A1A)),
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
                    color: selected
                        ? Colors.white
                        : const Color(0xFF43474F),
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

// ── Empty attendance state ────────────────────────────────────────────────────

class _EmptyAttendanceCard extends StatelessWidget {
  const _EmptyAttendanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E3E5)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x05000000),
              blurRadius: 16,
              offset: Offset(0, 4)),
        ],
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
            'Data kehadiran akan muncul setelah siswa\nmelakukan absensi.',
            style: TextStyle(fontSize: 12, color: Color(0xFF747780)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
