import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

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
  void dispose() {
    _nisnCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).login(
          _nisnCtrl.text.trim(),
          _passwordCtrl.text,
        );

    if (!mounted) return;
    final authState = ref.read(authProvider);
    authState.whenOrNull(
      data: (user) {
        if (user == null) return;
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text('Halo, ${user.fullname}!'),
          description: const Text('Login berhasil'),
          autoCloseDuration: const Duration(seconds: 2),
          alignment: Alignment.topCenter,
        );
      },
      error: (err, _) {
        final msg = err is AppException ? err.message : err.toString();
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text('Login Gagal'),
          description: Text(msg),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ─────────────────────────────────────────────
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC4C6D0), width: 1.5),
                    color: Colors.white,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset('assets/images/logoAMBIS.png', fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SMAN 07 Tangerang',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF002B5B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Portal Akademik Siswa',
                  style: TextStyle(fontSize: 13, color: Color(0xFF43474F)),
                ),
                const SizedBox(height: 24),

                // ── Card ───────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC4C6D0).withAlpha(80)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // NISN field
                              const _FieldLabel('NISN / USERNAME'),
                              const SizedBox(height: 8),
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
                              const SizedBox(height: 20),

                              // Password field
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const _FieldLabel('PASSWORD'),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Lupa Password?',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF006A63),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Password Anda',
                                  hintStyle: const TextStyle(color: Color(0xFF9EA3AB), fontSize: 14),
                                  prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF747780)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      size: 20,
                                      color: const Color(0xFF747780),
                                    ),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F9FB),
                                  border: _border(),
                                  enabledBorder: _enabledBorder(),
                                  focusedBorder: _focusedBorder(),
                                  errorBorder: _errorBorder(),
                                  focusedErrorBorder: _errorBorder(focused: true),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                obscureText: _obscure,
                                autofillHints: const [AutofillHints.password],
                                textInputAction: TextInputAction.done,
                                validator: Validators.password,
                                enabled: !isLoading,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 24),

                              // Submit
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
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.login_rounded, size: 20),
                                  label: Text(
                                    isLoading ? 'Memproses...' : 'Masuk',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF002B5B),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(0xFF002B5B).withAlpha(120),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Face registration banner ────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEEF0),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFFC4C6D0).withAlpha(80),
                            ),
                          ),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF47FBEB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.face_unlock_rounded,
                                size: 22,
                                color: Color(0xFF002B5B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Presensi Wajah',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF191C1E),
                                    ),
                                  ),
                                  Text(
                                    'Belum terdaftar?',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF43474F)),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go('/nisn-verify'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF002B5B),
                                side: BorderSide(
                                  color: const Color(0xFFC4C6D0).withAlpha(130),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Daftar Sekarang'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Footer ─────────────────────────────────────────────
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Color(0xFF747780)),
                    SizedBox(width: 6),
                    Text(
                      'Butuh bantuan? Hubungi Admin IT.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF747780)),
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
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Color(0xFF43474F),
        ),
      );
}

InputDecoration _inputDeco({required String hint, required IconData icon}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9EA3AB), fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF747780)),
      filled: true,
      fillColor: const Color(0xFFF7F9FB),
      border: _border(),
      enabledBorder: _enabledBorder(),
      focusedBorder: _focusedBorder(),
      errorBorder: _errorBorder(),
      focusedErrorBorder: _errorBorder(focused: true),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

OutlineInputBorder _border() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFC4C6D0)),
    );

OutlineInputBorder _enabledBorder() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: const Color(0xFFC4C6D0).withAlpha(130)),
    );

OutlineInputBorder _focusedBorder() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF006A63), width: 1.5),
    );

OutlineInputBorder _errorBorder({bool focused = false}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.red,
        width: focused ? 1.5 : 1.0,
      ),
    );
