import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient? client;

  AuthRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;
  bool get isAuthenticated => currentUser != null;

  /// Registrasi akun pemilik baru (US05-AC1, US05-AC2)
  /// Konfirmasi email dimatikan pada Supabase Auth sehingga langsung mengembalikan Session/User aktif.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('already in use') ||
          e.statusCode == '422') {
        throw const AuthException('Email sudah digunakan');
      }
      rethrow;
    }
  }

  /// Login pemilik kos dengan email & password (US05-AC3, US05-AC4)
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials') ||
          e.message.toLowerCase().contains('invalid') ||
          e.statusCode == '400') {
        throw const AuthException('Email atau password salah');
      }
      rethrow;
    }
  }

  /// Logout pemilik kos
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
