import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/user_entity.dart';

export '../models/user_entity.dart';

/// Maps a NISN to a synthetic Supabase Auth email so we can lean on
/// Supabase Auth (Argon2 hashed passwords + JWT) instead of rolling our
/// own crypto on-device.
String nisnToEmail(String nisn) =>
    '${nisn.trim()}@${AppConstants.authEmailDomain}';

class AuthRepository {
  AuthRepository({
    required this.supabase,
    required this.storage,
  });

  final sb.SupabaseClient supabase;
  final SecureStorageService storage;

  Future<UserEntity> login({
    required String nisn,
    required String password,
  }) async {
    final email = nisnToEmail(nisn);

    final sb.AuthResponse res;
    try {
      res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    }

    final session = res.session;
    final user = res.user;
    if (session == null || user == null) {
      throw const AuthException('NISN atau password salah.');
    }

    // Fetch the application user row so we know the role + display name.
    final Map<String, dynamic> profile;
    try {
      profile = await supabase
          .from('users')
          .select(
            'id, nisn, role, fullname, email, phone, avatar_url, is_active',
          )
          .eq('id', user.id)
          .single();
    } on sb.PostgrestException catch (e) {
      throw AuthException('Gagal memuat profil: ${e.message}');
    }

    if ((profile['is_active'] as bool? ?? true) == false) {
      throw const AuthException('Akun dinonaktifkan. Hubungi admin.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final entity = UserEntity(
      id: profile['id'] as String,
      nisn: profile['nisn'] as String,
      passwordHash: '',
      role: profile['role'] as String,
      fullname: profile['fullname'] as String,
      email: profile['email'] as String?,
      phone: profile['phone'] as String?,
      avatarUrl: profile['avatar_url'] as String?,
      isActive: profile['is_active'] as bool? ?? true,
      createdAt: now,
      updatedAt: now,
      syncedAt: now,
    );

    await storage.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      userId: entity.id,
      role: entity.role,
    );

    return entity;
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {
      // Ignore network errors on logout — we still want the local clear.
    }
    await storage.clear();
  }

  /// Reconstructs the current user from Supabase session + remote profile.
  /// Returns null when not signed in or on network error.
  Future<UserEntity?> getCurrentUser() async {
    final userId = await storage.getUserId();
    if (userId == null) return null;

    try {
      final profile = await supabase
          .from('users')
          .select('id, nisn, role, fullname, email, phone, avatar_url, is_active')
          .eq('id', userId)
          .single();

      final now = DateTime.now().millisecondsSinceEpoch;
      return UserEntity(
        id: profile['id'] as String,
        nisn: profile['nisn'] as String,
        passwordHash: '',
        role: profile['role'] as String,
        fullname: profile['fullname'] as String,
        email: profile['email'] as String?,
        phone: profile['phone'] as String?,
        avatarUrl: profile['avatar_url'] as String?,
        isActive: profile['is_active'] as bool? ?? true,
        createdAt: now,
        updatedAt: now,
        syncedAt: now,
      );
    } catch (_) {
      // Network unavailable — cannot reconstruct user without local cache.
      return null;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    supabase: sb.Supabase.instance.client,
    storage: ref.watch(secureStorageProvider),
  );
});
