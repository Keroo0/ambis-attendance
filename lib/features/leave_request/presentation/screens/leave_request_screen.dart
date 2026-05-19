import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/leave_provider.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _reasonCtrl = TextEditingController();
  final _picker = ImagePicker();

  String _permitType = 'Sakit';
  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  bool _submitting = false;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _prefillFrom(Map<String, dynamic> leave) {
    setState(() {
      _permitType = leave['type'] == 'sakit' ? 'Sakit' : 'Izin';
      _startDate = leave['date_from'] != null ? DateTime.tryParse(leave['date_from'] as String) : null;
      _endDate = leave['date_to'] != null ? DateTime.tryParse(leave['date_to'] as String) : null;
      _reasonCtrl.text = leave['reason'] as String? ?? '';
      _imageFile = null;
    });
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Pilih tanggal';
    return '${d.day} ${_monthNames[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF006A63),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    final path = xfile.path.toLowerCase();
    if (!path.endsWith('.jpg') && !path.endsWith('.jpeg')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format file harus JPG/JPEG.')),
      );
      return;
    }
    setState(() => _imageFile = File(xfile.path));
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal izin terlebih dahulu.')),
      );
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keterangan wajib diisi.')),
      );
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto bukti wajib diupload.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(leaveProvider.notifier).submit(
            uiType: _permitType,
            reason: _reasonCtrl.text.trim(),
            dateFrom: _startDate!,
            dateTo: _endDate!,
            imageFile: _imageFile!,
          );

      if (!mounted) return;
      final providerState = ref.read(leaveProvider);
      if (providerState is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Gagal: ${(providerState as AsyncError).error}')),
        );
        return;
      }

      setState(() {
        _permitType = 'Sakit';
        _startDate = null;
        _endDate = null;
        _imageFile = null;
        _reasonCtrl.clear();
      });
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Pengajuan Terkirim'),
          content: const Text(
              'Pengajuan izin Anda sedang menunggu persetujuan wali kelas.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(color: Color(0xFF006A63))),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leavesAsync = ref.watch(leaveProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────
            Container(
              height: 64,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF002B5B)),
                  ),
                  const Expanded(
                    child: Text(
                      'SMAN 07 Tangerang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF002B5B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined,
                        color: Color(0xFF002B5B)),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ───────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Page title
                        const Text(
                          'Submit Permit',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF001736),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Isi formulir di bawah untuk mengajukan izin kehadiran.',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF43474F),
                              height: 1.5),
                        ),
                        const SizedBox(height: 20),

                        // ── Form card ─────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left teal accent bar
                                Container(
                                  width: 4,
                                  color: const Color(0xFF47FBEB),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                              // Permit type
                              const _SectionLabel('PERMIT TYPE'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _PermitTypeButton(
                                      label: 'Sakit',
                                      selected: _permitType == 'Sakit',
                                      onTap: () => setState(
                                          () => _permitType = 'Sakit'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _PermitTypeButton(
                                      label: 'Izin',
                                      selected: _permitType == 'Izin',
                                      onTap: () => setState(
                                          () => _permitType = 'Izin'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Date range
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const _SectionLabel('START DATE'),
                                        const SizedBox(height: 8),
                                        _DatePickerField(
                                          value: _formatDate(_startDate),
                                          hasValue: _startDate != null,
                                          onTap: () =>
                                              _pickDate(isStart: true),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const _SectionLabel('END DATE'),
                                        const SizedBox(height: 8),
                                        _DatePickerField(
                                          value: _formatDate(_endDate),
                                          hasValue: _endDate != null,
                                          onTap: () =>
                                              _pickDate(isStart: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Reason
                              const _SectionLabel('REASON'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _reasonCtrl,
                                maxLines: 3,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF191C1E)),
                                decoration: InputDecoration(
                                  hintText:
                                      'Jelaskan alasan absen Anda...',
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF9EA3AB),
                                      fontSize: 14),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F9FB),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFC4C6D0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: const Color(0xFFC4C6D0)
                                            .withAlpha(150)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF47FBEB),
                                        width: 1.5),
                                  ),
                                ),
                                enabled: !_submitting,
                              ),
                              const SizedBox(height: 16),

                              // Attachment
                              const _SectionLabel(
                                  "ATTACHMENT (DOCTOR'S NOTE / LETTER)"),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap:
                                    _submitting ? null : _pickImage,
                                child: CustomPaint(
                                  painter: const _DashedBorderPainter(
                                    color: Color(0xFFC4C6D0),
                                    radius: 8,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F9FB),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: _imageFile != null
                                        ? Column(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .check_circle_rounded,
                                                size: 36,
                                                color:
                                                    Color(0xFF006A63),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _imageFile!.path
                                                    .split('/')
                                                    .last,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      Color(0xFF006A63),
                                                  fontWeight:
                                                      FontWeight.w500,
                                                ),
                                                textAlign:
                                                    TextAlign.center,
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Tap untuk ganti file',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(
                                                        0xFF747780)),
                                              ),
                                            ],
                                          )
                                        : const Column(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons
                                                    .upload_file_rounded,
                                                size: 36,
                                                color:
                                                    Color(0xFF747780),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Tap untuk upload file',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      Color(0xFF43474F),
                                                  fontWeight:
                                                      FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'JPG/JPEG (Maks 1 MB)',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      Color(0xFF747780),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Submit button ─────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _submitting ? null : _submit,
                            icon: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Icon(Icons.send_rounded,
                                    size: 18),
                            label: Text(
                              _submitting ? 'Mengirim...' : 'Submit Permit',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002B5B),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF002B5B).withAlpha(120),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                          ),
                        ),

                        // ── History section ───────────────────────────
                        const SizedBox(height: 28),
                        const Text(
                          'Riwayat Pengajuan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191C1E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        leavesAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                                child: CircularProgressIndicator()),
                          ),
                          error: (e, _) => const Text(
                            'Gagal memuat riwayat. Coba lagi nanti.',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                          data: (leaves) => leaves.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 24),
                                  child: Center(
                                    child: Text(
                                      'Belum ada pengajuan.',
                                      style: TextStyle(
                                          color: Color(0xFF747780)),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: leaves
                                      .map((l) => _LeaveCard(
                                            leave: l,
                                            onResubmit: l['status'] == 'rejected'
                                                ? () => _prefillFrom(l)
                                                : null,
                                          ))
                                      .toList(),
                                ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  if (_submitting)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                          child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small reusable widgets ─────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Color(0xFF43474F),
        ),
      );
}

class _PermitTypeButton extends StatelessWidget {
  const _PermitTypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF47FBEB).withAlpha(25)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xFF47FBEB)
                : const Color(0xFFC4C6D0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected
                  ? const Color(0xFF00DECF)
                  : const Color(0xFF43474F),
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.value,
    required this.hasValue,
    required this.onTap,
  });

  final String value;
  final bool hasValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xFFC4C6D0).withAlpha(150)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: hasValue
                      ? const Color(0xFF191C1E)
                      : const Color(0xFF9EA3AB),
                ),
              ),
            ),
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: Color(0xFF747780)),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 7.0;
    const dashSpace = 4.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

// ── Leave history card ─────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave, this.onResubmit});

  final Map<String, dynamic> leave;
  final VoidCallback? onResubmit;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String get _status => leave['status'] as String? ?? 'pending';

  Color get _statusColor => switch (_status) {
        'approved' => const Color(0xFF006A63),
        'rejected' => Colors.red,
        _ => const Color(0xFFF5B800),
      };

  String get _statusLabel => switch (_status) {
        'approved' => 'Disetujui',
        'rejected' => 'Ditolak',
        _ => 'Menunggu',
      };

  IconData get _statusIcon => switch (_status) {
        'approved' => Icons.check_circle_outline_rounded,
        'rejected' => Icons.cancel_outlined,
        _ => Icons.hourglass_empty_rounded,
      };

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    final month = int.tryParse(parts[1]) ?? 1;
    return '${parts[2]} ${_monthNames[month - 1]} ${parts[0]}';
  }

  String get _dateRange {
    final from = leave['date_from'] as String?;
    final to = leave['date_to'] as String?;
    if (from == null || to == null) return '-';
    if (from == to) return _formatDate(from);
    return '${_formatDate(from)} – ${_formatDate(to)}';
  }

  @override
  Widget build(BuildContext context) {
    final type = leave['type'] as String? ?? '';
    final reason = leave['reason'] as String?;
    final rejectedReason = leave['rejected_reason'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC4C6D0).withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        type == 'sakit' ? 'Sakit' : 'Izin',
                        style: const TextStyle(
                          color: Color(0xFF191C1E),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$_dateRange  ·  ${reason ?? ''}',
                  style: const TextStyle(color: Color(0xFF747780), fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (rejectedReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Alasan penolakan: $rejectedReason',
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ],
                if (onResubmit != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onResubmit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002B5B).withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF002B5B).withAlpha(60)),
                      ),
                      child: const Text(
                        'Ajukan Ulang',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF002B5B),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
