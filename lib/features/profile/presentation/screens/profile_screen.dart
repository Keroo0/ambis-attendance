import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../grades/data/repositories/grade_repository.dart';

final _profileGradeSummaryProvider =
    FutureProvider.autoDispose<GradeSummary?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  final repo = ref.read(gradeRepositoryProvider);
  final now = DateTime.now();
  final semester = now.month >= 7 ? 1 : 2;
  final result = await repo.getGradesFromSupabase(user.id, semester);
  return result.$2;
});

final _waliKelasProvider = FutureProvider.autoDispose<String?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  try {
    final row = await sb.Supabase.instance.client
        .from('students')
        .select('homeroom_teacher')
        .eq('id', user.id)
        .maybeSingle();
    return row?['homeroom_teacher'] as String?;
  } catch (_) {
    return null;
  }
});

final _profileStudentProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  try {
    final row = await sb.Supabase.instance.client
        .from('students')
        .select(
            'id, nisn, class, parent_id, date_of_birth, gender, address, phone_parent, created_at, updated_at')
        .eq('id', user.id)
        .maybeSingle();
    return row;
  } catch (_) {
    return null;
  }
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploadingPhoto = false;

  // ── Foto Profil ──────────────────────────────────────────────────────────

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    CroppedFile? croppedFile;
    if (!kIsWeb) {
      croppedFile = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur Foto Profil',
            toolbarColor: const Color(0xFF002B5B),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.secondary,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
          ),
          IOSUiSettings(
            title: 'Atur Foto Profil',
            aspectRatioLockEnabled: true,
            cropStyle: CropStyle.circle,
          ),
        ],
      );
      if (croppedFile == null) return; // Batal crop
    }

    setState(() => _uploadingPhoto = true);
    try {
      var bytes = croppedFile != null
          ? await croppedFile.readAsBytes()
          : await picked.readAsBytes();

      if (!kIsWeb) {
        final compressed = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 400,
          minHeight: 400,
          quality: 80,
          format: CompressFormat.jpeg,
        );
        bytes = compressed;
      }

      final user = ref.read(authProvider).valueOrNull;
      if (user == null) return;

      final supabase = sb.Supabase.instance.client;
      final path = '${user.id}/photo.jpg';
      final now = DateTime.now().millisecondsSinceEpoch;

      await supabase.storage.from('profile-photos').uploadBinary(
            path,
            bytes,
            fileOptions: const sb.FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final baseUrl =
          supabase.storage.from('profile-photos').getPublicUrl(path);
      final url = '$baseUrl?v=$now';

      await supabase
          .from('users')
          .update({'avatar_url': url, 'updated_at': now}).eq('id', user.id);

      await ref.read(authProvider.notifier).refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e is sb.StorageException
            ? e.message
            : e is Exception
                ? e.toString().replaceFirst('Exception: ', '')
                : 'Terjadi kesalahan.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $msg')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC4C6D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ubah Foto Profil',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Ambil dari Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Ganti Password ───────────────────────────────────────────────────────

  void _showChangePasswordSheet() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool loading = false;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC4C6D0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ubah Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF001736),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Masukkan password lama lalu buat password baru (min. 6 karakter).',
                    style: TextStyle(fontSize: 13, color: Color(0xFF747780)),
                  ),
                  const SizedBox(height: 20),
                  _PasswordField(
                    controller: oldPassCtrl,
                    label: 'Password Lama',
                    hint: 'Masukkan password saat ini',
                    obscure: obscureOld,
                    onToggle: () =>
                        setSheetState(() => obscureOld = !obscureOld),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE8EAED)),
                  const SizedBox(height: 16),
                  _PasswordField(
                    controller: newPassCtrl,
                    label: 'Password Baru',
                    hint: 'Masukkan password baru',
                    obscure: obscureNew,
                    onToggle: () =>
                        setSheetState(() => obscureNew = !obscureNew),
                  ),
                  const SizedBox(height: 12),
                  _PasswordField(
                    controller: confirmCtrl,
                    label: 'Konfirmasi Password Baru',
                    hint: 'Ulangi password baru',
                    obscure: obscureConfirm,
                    onToggle: () =>
                        setSheetState(() => obscureConfirm = !obscureConfirm),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMsg!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              final op = oldPassCtrl.text.trim();
                              final np = newPassCtrl.text.trim();
                              final cp = confirmCtrl.text.trim();

                              if (op.isEmpty) {
                                setSheetState(
                                    () => errorMsg = 'Masukkan password lama');
                                return;
                              }
                              if (np.length < 6) {
                                setSheetState(() => errorMsg =
                                    'Password baru minimal 6 karakter');
                                return;
                              }
                              if (np != cp) {
                                setSheetState(() => errorMsg =
                                    'Konfirmasi password tidak cocok');
                                return;
                              }

                              setSheetState(() => loading = true);
                              try {
                                final user = ref.read(authProvider).valueOrNull;
                                if (user == null) {
                                  setSheetState(() {
                                    errorMsg =
                                        'Sesi berakhir, silakan login ulang.';
                                    loading = false;
                                  });
                                  return;
                                }

                                final email = '${user.nisn}@sman07.local';
                                await sb.Supabase.instance.client.auth
                                    .signInWithPassword(
                                  email: email,
                                  password: op,
                                );

                                await sb.Supabase.instance.client.auth
                                    .updateUser(
                                  sb.UserAttributes(password: np),
                                );

                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Password berhasil diperbarui'),
                                    ),
                                  );
                                }
                              } on sb.AuthException catch (e) {
                                setSheetState(() {
                                  errorMsg = e.message.contains('Invalid')
                                      ? 'Password lama salah'
                                      : e.message;
                                  loading = false;
                                });
                              } catch (e) {
                                setSheetState(() {
                                  errorMsg = 'Terjadi kesalahan: $e';
                                  loading = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001736),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String _semesterLabel() {
    final now = DateTime.now();
    if (now.month >= 7) {
      return 'Ganjil ${now.year}/${(now.year + 1).toString().substring(2)}';
    } else {
      return 'Genap ${now.year - 1}/${now.year.toString().substring(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final studentAsync = ref.watch(_profileStudentProvider);
    final waliKelas = ref.watch(_waliKelasProvider).valueOrNull;
    final gradeSummary = ref.watch(_profileGradeSummaryProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onNotification: () => context.push('/notifications')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  _ProfileHeaderCard(
                    user: user,
                    className: studentAsync.valueOrNull?['class'] as String?,
                    uploadingPhoto: _uploadingPhoto,
                    onEditPhoto: _pickAndUploadPhoto,
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel(text: 'Data Akademik'),
                  const SizedBox(height: 8),
                  _DataAkademikSection(
                    isActive: user?.isActive ?? false,
                    waliKelas: waliKelas,
                    semesterLabel: _semesterLabel(),
                    rataRata: gradeSummary?.overallAverage,
                    isLulus: gradeSummary?.overallAverage != null
                        ? (gradeSummary!.overallAverage! >= 75)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel(text: 'Pengaturan Akun'),
                  const SizedBox(height: 8),
                  _PengaturanCard(
                    onNotifikasi: () => context.push('/notifications'),
                    onUbahPassword: _showChangePasswordSheet,
                  ),
                  const SizedBox(height: 24),
                  _LogoutButton(
                    onTap: () => _confirmLogout(context, ref),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Versi Aplikasi 1.0.0 (Stable)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF747780),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }
  }
}

// ── Password Field Helper ─────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF747780),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B3BB), fontSize: 14),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
                color: const Color(0xFF747780),
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC4C6D0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC4C6D0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF006A63), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotification});

  final VoidCallback onNotification;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E3E8)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF002B5B),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/LogoAMBIS.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'SMAN 07 Tangerang',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF002B5B),
              ),
            ),
          ),
          IconButton(
            onPressed: onNotification,
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF43474F),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Header Card ───────────────────────────────────────────────────────

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.user,
    required this.className,
    required this.uploadingPhoto,
    required this.onEditPhoto,
  });

  final UserEntity? user;
  final String? className;
  final bool uploadingPhoto;
  final VoidCallback onEditPhoto;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.fullname ?? '-';
    final nisn = user?.nisn ?? '-';
    final kelas = className ?? '-';
    final avatarUrl = user?.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C6D0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: uploadingPhoto ? null : onEditPhoto,
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tertiaryFixedDim,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 3,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: uploadingPhoto
                      ? const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : avatarUrl != null
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  _initials(name),
                                  style: const TextStyle(
                                    color: Color(0xFF001736),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                _initials(name),
                                style: const TextStyle(
                                  color: Color(0xFF001736),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF001736),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'NISN: $nisn',
            style: const TextStyle(
              color: Color(0xFF747780),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF002B5B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF002B5B).withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school_rounded,
                  color: AppColors.secondary,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  kelas,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF001736),
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ── Data Akademik Section ─────────────────────────────────────────────────────

class _DataAkademikSection extends StatelessWidget {
  const _DataAkademikSection({
    required this.isActive,
    required this.waliKelas,
    required this.semesterLabel,
    this.rataRata,
    this.isLulus,
  });

  final bool isActive;
  final String? waliKelas;
  final String semesterLabel;
  final double? rataRata;
  final bool? isLulus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AkademikCard(
          label: 'WALI KELAS',
          icon: Icons.person_rounded,
          child: Text(
            waliKelas ?? '-',
            style: const TextStyle(
              color: Color(0xFF001736),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AkademikCard(
                label: 'SEMESTER',
                icon: Icons.calendar_today_rounded,
                child: Text(
                  semesterLabel,
                  style: const TextStyle(
                    color: Color(0xFF001736),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AkademikCard(
                label: 'STATUS',
                icon: null,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFF747780),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF059669)
                            : const Color(0xFF747780),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AkademikCard(
                label: 'RATA-RATA NILAI',
                icon: Icons.bar_chart_rounded,
                child: Text(
                  rataRata != null ? rataRata!.toStringAsFixed(1) : '–',
                  style: const TextStyle(
                    color: Color(0xFF001736),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AkademikCard(
                label: 'KETERANGAN',
                icon: null,
                child: isLulus == null
                    ? const Text(
                        '–',
                        style: TextStyle(
                          color: Color(0xFF747780),
                          fontSize: 14,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLulus!
                              ? const Color(0xFF006A63).withAlpha(20)
                              : Colors.red.withAlpha(20),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isLulus!
                                ? const Color(0xFF006A63).withAlpha(60)
                                : Colors.red.withAlpha(60),
                          ),
                        ),
                        child: Text(
                          isLulus! ? 'Lulus' : 'Tidak Lulus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                isLulus! ? const Color(0xFF006A63) : Colors.red,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AkademikCard extends StatelessWidget {
  const _AkademikCard({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppColors.secondary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF747780),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (icon != null) ...[
                      Row(
                        children: [
                          Icon(icon, color: AppColors.secondary, size: 18),
                          const SizedBox(width: 6),
                          Expanded(child: child),
                        ],
                      ),
                    ] else
                      child,
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

// ── Pengaturan Akun Card ──────────────────────────────────────────────────────

class _PengaturanCard extends StatelessWidget {
  const _PengaturanCard({
    required this.onNotifikasi,
    required this.onUbahPassword,
  });

  final VoidCallback onNotifikasi;
  final VoidCallback onUbahPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.lock_reset_rounded,
            label: 'Ubah PIN / Password',
            onTap: onUbahPassword,
            isFirst: true,
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.notifications_active_rounded,
            label: 'Pengaturan Notifikasi',
            onTap: onNotifikasi,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0x1AC4C6D0),
      indent: 56,
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF001736).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF001736), size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF191C1E),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF747780),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Keluar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
