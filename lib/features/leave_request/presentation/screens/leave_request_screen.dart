import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../data/dummy_leaves.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();

  String? _jenisIzin;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedFileName;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: AppColors.background,
            surface: AppColors.surface,
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal izin terlebih dahulu.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Pengajuan Terkirim',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Pengajuan izin Anda sedang menunggu persetujuan wali kelas.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Izin')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            // ── Form Card ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(Spacing.borderRadius),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengajuan Baru',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: Spacing.md),

                    // Jenis Izin
                    DropdownButtonFormField<String>(
                      initialValue: _jenisIzin,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Izin',
                        prefixIcon: Icon(Icons.category_outlined,
                            color: AppColors.textHint, size: 20),
                      ),
                      dropdownColor: AppColors.surfaceAlt,
                      items: const [
                        DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                        DropdownMenuItem(
                            value: 'Izin Keluarga',
                            child: Text('Izin Keluarga')),
                        DropdownMenuItem(
                            value: 'Keperluan Lain',
                            child: Text('Keperluan Lain')),
                      ],
                      onChanged: (v) => setState(() => _jenisIzin = v),
                      validator: (v) =>
                          v == null ? 'Pilih jenis izin' : null,
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Tanggal Mulai
                    _DateField(
                      label: 'Tanggal Mulai',
                      date: _startDate,
                      onTap: () => _pickDate(isStart: true),
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Tanggal Selesai
                    _DateField(
                      label: 'Tanggal Selesai',
                      date: _endDate,
                      onTap: () => _pickDate(isStart: false),
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Keterangan
                    TextFormField(
                      controller: _keteranganController,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                        hintText: 'Jelaskan alasan izin secara singkat...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Keterangan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Upload bukti
                    _UploadButton(
                      fileName: _selectedFileName,
                      onTap: () => setState(
                          () => _selectedFileName = 'surat_keterangan.jpg'),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Format JPG/JPEG, ukuran maks 1 MB.',
                      style: TextStyle(
                          color: AppColors.textHint, fontSize: 11),
                    ),
                    const SizedBox(height: Spacing.md),

                    // Submit
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.background,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Spacing.borderRadius),
                        ),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        'Kirim Pengajuan',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: Spacing.lg),

            // ── Riwayat Pengajuan ──────────────────────────────────────
            const Text(
              'Riwayat Pengajuan',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            ...kDummyLeaves.map((leave) => _LeaveCard(leave: leave)),
          ],
        ),
      ),
    );
  }
}

// ── Date field ────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String get _text => date != null
      ? '${date!.day} ${_monthNames[date!.month - 1]} ${date!.year}'
      : 'Pilih tanggal';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.borderRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          _text,
          style: TextStyle(
            color: date != null ? AppColors.textPrimary : AppColors.textHint,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ── Upload button ─────────────────────────────────────────────────────────────

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.fileName, required this.onTap});

  final String? fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return OutlinedButton.icon(
      icon: Icon(
        hasFile ? Icons.check_circle_outline_rounded : Icons.upload_file_rounded,
        size: 18,
      ),
      label: Text(
        hasFile ? fileName! : 'Upload Foto Bukti',
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: hasFile ? AppColors.success : AppColors.secondary,
        side: BorderSide(
            color: hasFile ? AppColors.success : AppColors.primary),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.borderRadius),
        ),
      ),
      onPressed: onTap,
    );
  }
}

// ── Leave card ────────────────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave});

  final DummyLeaveRequest leave;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  Color get _statusColor {
    switch (leave.status) {
      case LeaveStatus.pending:
        return AppColors.warning;
      case LeaveStatus.approved:
        return AppColors.success;
      case LeaveStatus.rejected:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (leave.status) {
      case LeaveStatus.pending:
        return 'Menunggu';
      case LeaveStatus.approved:
        return 'Disetujui';
      case LeaveStatus.rejected:
        return 'Ditolak';
    }
  }

  IconData get _statusIcon {
    switch (leave.status) {
      case LeaveStatus.pending:
        return Icons.hourglass_empty_rounded;
      case LeaveStatus.approved:
        return Icons.check_circle_outline_rounded;
      case LeaveStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  String _dateRange() {
    final s = leave.startDate;
    final e = leave.endDate;
    if (s.year == e.year && s.month == e.month && s.day == e.day) {
      return '${s.day} ${_monthNames[s.month - 1]} ${s.year}';
    }
    if (s.month == e.month && s.year == e.year) {
      return '${s.day}–${e.day} ${_monthNames[s.month - 1]} ${s.year}';
    }
    return '${s.day} ${_monthNames[s.month - 1]} – ${e.day} ${_monthNames[e.month - 1]} ${e.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.xs),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 18),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        leave.type,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(31),
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
                  '${_dateRange()}  ·  ${leave.reason}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (leave.rejectionReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Alasan penolakan: ${leave.rejectionReason}',
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 11),
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
