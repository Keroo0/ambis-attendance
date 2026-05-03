import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/secure_storage_service.dart';

/// Maps a NISN to a synthetic Supabase Auth email so we can lean on
/// Supabase Auth (Argon2 hashed passwords + JWT) instead of rolling our
/// own crypto on-device.
String nisnToEmail(String nisn) =>
    '${nisn.trim()}@${AppConstants.authEmailDomain}';

class AuthRepository {
  AuthRepository({
    required this.supabase,
    required this.db,
    required this.storage,
  });

  final sb.SupabaseClient supabase;
  final AppDatabase db;
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

    // Cache locally for offline access.
    await db.into(db.users).insertOnConflictUpdate(
          UsersCompanion(
            id: drift.Value(entity.id),
            nisn: drift.Value(entity.nisn),
            passwordHash: const drift.Value(''),
            role: drift.Value(entity.role),
            fullname: drift.Value(entity.fullname),
            email: drift.Value(entity.email),
            phone: drift.Value(entity.phone),
            avatarUrl: drift.Value(entity.avatarUrl),
            isActive: drift.Value(entity.isActive),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
            syncedAt: drift.Value(now),
          ),
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

  Future<UserEntity?> getCurrentUser() async {
    final userId = await storage.getUserId();
    if (userId == null) return null;
    final query = db.select(db.users)..where((u) => u.id.equals(userId));
    return query.getSingleOrNull();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    supabase: sb.Supabase.instance.client,
    db: ref.watch(appDatabaseProvider),
    storage: ref.watch(secureStorageProvider),
  );
});
