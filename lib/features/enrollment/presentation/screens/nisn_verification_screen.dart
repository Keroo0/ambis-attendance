import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class NisnVerificationScreen extends StatefulWidget {
  const NisnVerificationScreen({super.key});

  @override
  State<NisnVerificationScreen> createState() => _NisnVerificationScreenState();
}

class _NisnVerificationScreenState extends State<NisnVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nisnCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nisnCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    // Navigate to login so the user authenticates; router will redirect to
    // /enrollment automatically when siswa is logged in but not enrolled.
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/welcome'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECEEF0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Color(0xFF191C1E),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Registrasi Wajah',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191C1E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Presensi Biometrik',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF43474F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ── Main ────────────────────────────────────────────────
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6E3FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          size: 48,
                          color: Color(0xFF002B5B),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Verifikasi NISN',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF002B5B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Masukkan NISN Anda untuk memverifikasi identitas sebelum mendaftarkan wajah.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF43474F),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'NISN SISWA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF43474F),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nisnCtrl,
                              decoration: InputDecoration(
                                hintText: 'Contoh: 0012345678',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9EA3AB),
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.badge_outlined,
                                  size: 20,
                                  color: Color(0xFF747780),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF7F9FB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFC4C6D0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color:
                                        const Color(0xFFC4C6D0).withAlpha(130),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF006A63),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.done,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'NISN tidak boleh kosong';
                                }
                                if (v.trim().length < 6) {
                                  return 'NISN minimal 6 digit';
                                }
                                return null;
                              },
                              enabled: !_loading,
                              onFieldSubmitted: (_) => _verify(),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _loading ? null : _verify,
                                icon: _loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                label: Text(
                                  _loading ? 'Memverifikasi...' : 'Verifikasi NISN',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.help_outline,
                            size: 16,
                            color: Color(0xFF405F91),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Butuh bantuan? Hubungi Admin IT',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF405F91),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
