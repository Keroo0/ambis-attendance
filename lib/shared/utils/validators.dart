class Validators {
  Validators._();

  static String? nisn(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'NISN tidak boleh kosong';
    if (v.length < 6) return 'NISN minimal 6 karakter';
    if (!RegExp(r'^[0-9A-Za-z]+$').hasMatch(v)) {
      return 'NISN hanya boleh angka/huruf';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < 6) return 'Password minimal 6 karakter';
    return null;
  }
}
