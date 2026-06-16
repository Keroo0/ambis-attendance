import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/constants/design_tokens.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../shared/utils/validators.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nisnCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // ✅ FIX BLUNDER #2: State Management — ref.listen (declarative)
    // Listen to auth state changes and react automatically
    ref.listenManual(authProvider, (prev, next) {
      if (!mounted) return;

      next.whenOrNull(
        data: (user) {
          if (user == null) return;
          toastification.show(
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            title: Text('Halo, ${user.fullname}!', style: DesignTokens.bodyLg),
            description:
                const Text('Login berhasil', style: DesignTokens.bodySm),
            autoCloseDuration: const Duration(seconds: 2),
            alignment: Alignment.topCenter,
          );
        },
        error: (err, _) {
          final msg = err is AppException ? err.message : err.toString();
          toastification.show(
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            title: const Text('Login Gagal', style: DesignTokens.bodyLg),
            description: Text(msg, style: DesignTokens.bodySm),
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.topCenter,
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _nisnCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // ✅ Clean submission — no imperative state reading
    await ref.read(authProvider.notifier).login(
          _nisnCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX BLUNDER #3: Using Design Tokens
    // ✅ FIX BLUNDER #2: Watch loading state declaratively
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing16,
              vertical: DesignTokens.spacing32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: isLoading ? null : () => context.go('/welcome'),
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    color: DesignTokens.onSurface,
                    style: IconButton.styleFrom(
                      backgroundColor: DesignTokens.surface,
                      disabledBackgroundColor: DesignTokens.surfaceContainer,
                      side: const BorderSide(
                        color: DesignTokens.outlineVariant,
                        width: 1,
                      ),
                    ),
                    tooltip: 'Kembali',
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing12),

                // ── Logo ─────────────────────────────────
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: DesignTokens.outlineVariant, width: 1),
                    color: DesignTokens.surface,
                  ),
                  clipBehavior: Clip.hardEdge,
                  // ✅ FIX: Correct asset name (LogoAMBIS.png with capital L)
                  child: Image.asset('assets/images/LogoAMBIS.png',
                      fit: BoxFit.cover),
                ),
                const SizedBox(height: DesignTokens.spacing16),

                // ── Title ────────────────────────────────
                Text(
                  'SMAN 07 Tangerang',
                  style: DesignTokens.h2.copyWith(color: DesignTokens.primary),
                ),
                const SizedBox(height: DesignTokens.spacing8),
                const Text(
                  'Portal Akademik Siswa',
                  style: DesignTokens.bodySm,
                ),
                const SizedBox(height: DesignTokens.spacing24),

                // ── Card ────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: DesignTokens.surface,
                    borderRadius: DesignTokens.radius16,
                    border: Border.all(
                        color: DesignTokens.outlineVariant, width: 1),
                    boxShadow: [DesignTokens.cardShadow],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(DesignTokens.spacing24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // NISN Field
                              const _FieldLabel('NISN / USERNAME'),
                              const SizedBox(height: DesignTokens.spacing8),
                              TextFormField(
                                controller: _nisnCtrl,
                                decoration: _inputDeco(
                                  hint: 'Masukkan NISN Anda',
                                  icon: Icons.person_outline,
                                ),
                                keyboardType: TextInputType.text,
                                autofillHints: const [AutofillHints.username],
                                textInputAction: TextInputAction.next,
                                validator: Validators.nisn,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: DesignTokens.spacing20),

                              // Password Field
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const _FieldLabel('PASSWORD'),
                                  TextButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Lupa Password?'),
                                        content: const Text(
                                          'Hubungi Admin IT atau Wali Kelas untuk reset password Anda.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Lupa Password?',
                                      style: DesignTokens.smallText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: DesignTokens.spacing8),
                              TextFormField(
                                controller: _passwordCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Password Anda',
                                  hintStyle: DesignTokens.bodySm.copyWith(
                                    color: DesignTokens.hintText,
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      size: 20,
                                      color: DesignTokens.iconDefault),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: DesignTokens.iconDefault,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                  filled: true,
                                  fillColor: DesignTokens.background,
                                  border: DesignTokens.inputBorder,
                                  enabledBorder:
                                      DesignTokens.inputEnabledBorder,
                                  focusedBorder:
                                      DesignTokens.inputFocusedBorder,
                                  errorBorder: DesignTokens.inputErrorBorder,
                                  focusedErrorBorder:
                                      DesignTokens.inputErrorFocusedBorder,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: DesignTokens.spacing16,
                                    vertical: 14,
                                  ),
                                ),
                                obscureText: _obscure,
                                autofillHints: const [AutofillHints.password],
                                textInputAction: TextInputAction.done,
                                validator: Validators.password,
                                enabled: !isLoading,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: DesignTokens.spacing24),

                              // Submit Button
                              SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : _submit,
                                  icon: isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: DesignTokens.onPrimary,
                                          ),
                                        )
                                      : const Icon(Icons.login_rounded,
                                          size: 20),
                                  label: Text(
                                    isLoading ? 'Memproses...' : 'Masuk',
                                    style: DesignTokens.buttonText,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: DesignTokens.primary,
                                    foregroundColor: DesignTokens.onPrimary,
                                    disabledBackgroundColor:
                                        DesignTokens.primary.withAlpha(120),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: DesignTokens.radius8,
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Face Registration Banner ────────
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacing24,
                            vertical: DesignTokens.spacing20,
                          ),
                          decoration: const BoxDecoration(
                            color: DesignTokens.surfaceContainer,
                            border: Border(
                              top: BorderSide(
                                  color: DesignTokens.outlineVariant, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: DesignTokens.cyanAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.face_unlock_rounded,
                                    size: 22, color: DesignTokens.primary),
                              ),
                              const SizedBox(width: DesignTokens.spacing12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Presensi Wajah',
                                      style: DesignTokens.caption,
                                    ),
                                    Text(
                                      'Belum terdaftar?',
                                      style: DesignTokens.smallText,
                                    ),
                                  ],
                                ),
                              ),
                              // ✅ FIX BLUNDER #1: Layout — Expanded gives finite constraint in Row
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.go('/nisn-verify'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: DesignTokens.primary,
                                    side: const BorderSide(
                                        color: DesignTokens.outlineVariant,
                                        width: 1),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: DesignTokens.spacing16,
                                      vertical: 10,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: DesignTokens.radius8,
                                    ),
                                    textStyle: DesignTokens.smallText.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text('Daftar Sekarang'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing24),

                // ── Footer ─────────────────────────────
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: DesignTokens.iconDefault),
                    SizedBox(width: DesignTokens.spacing8),
                    Text(
                      'Butuh bantuan? Hubungi Admin IT.',
                      style: DesignTokens.smallText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: DesignTokens.labelCaps,
      );
}

InputDecoration _inputDeco({required String hint, required IconData icon}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: DesignTokens.bodySm.copyWith(color: DesignTokens.hintText),
      prefixIcon: Icon(icon, size: 20, color: DesignTokens.iconDefault),
      filled: true,
      fillColor: DesignTokens.background,
      border: DesignTokens.inputBorder,
      enabledBorder: DesignTokens.inputEnabledBorder,
      focusedBorder: DesignTokens.inputFocusedBorder,
      errorBorder: DesignTokens.inputErrorBorder,
      focusedErrorBorder: DesignTokens.inputErrorFocusedBorder,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing16,
        vertical: 14,
      ),
    );
