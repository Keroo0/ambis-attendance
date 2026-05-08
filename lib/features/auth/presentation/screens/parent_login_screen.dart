import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../shared/utils/validators.dart';
import '../providers/auth_provider.dart';

class ParentLoginScreen extends ConsumerStatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  ConsumerState<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends ConsumerState<ParentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nisnCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _nisnCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).login(
          _nisnCtrl.text.trim(),
          _pinCtrl.text,
        );

    if (!mounted) return;
    final authState = ref.read(authProvider);
    authState.whenOrNull(
      data: (user) {
        if (user == null) return;
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: const Text('Selamat Datang!'),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Hero ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                height: 192,
                color: const Color(0xFF002B5B),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => context.go('/welcome'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.family_restroom_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'SMAN 07 Tangerang',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Portal Pemantauan Akademik',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Selamat Datang, Bapak/Ibu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF002B5B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Masuk menggunakan NISN putra-putri Anda dan PIN yang diberikan oleh sekolah.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF43474F),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // NISN Siswa
                      const _FieldLabel('NISN SISWA'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nisnCtrl,
                        decoration: _inputDeco(
                          hint: 'Masukkan NISN putra-putri Anda',
                          icon: Icons.badge_outlined,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: Validators.nisn,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 20),

                      // PIN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _FieldLabel('PIN / PASSWORD'),
                          TextButton(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Lupa PIN?'),
                                content: const Text(
                                  'Hubungi Wali Kelas untuk mendapatkan PIN baru.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Lupa PIN?',
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
                        controller: _pinCtrl,
                        decoration: InputDecoration(
                          hintText: 'Masukkan PIN Anda',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9EA3AB),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: Color(0xFF747780),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: const Color(0xFF747780),
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F9FB),
                          border: _border(),
                          enabledBorder: _enabledBorder(),
                          focusedBorder: _focusedBorder(),
                          errorBorder: _errorBorder(),
                          focusedErrorBorder: _errorBorder(focused: true),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),

                      // Remember me
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? false),
                              activeColor: const Color(0xFF002B5B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Ingat saya',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF43474F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Submit
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002B5B),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF002B5B).withAlpha(120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Masuk sebagai Orang Tua',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Center(
                        child: Text(
                          'Belum memiliki akses? Hubungi Wali Kelas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF747780),
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
      borderSide: BorderSide(color: Colors.red, width: focused ? 1.5 : 1.0),
    );
