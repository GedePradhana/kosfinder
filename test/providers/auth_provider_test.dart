import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthResponse extends AuthResponse {
  FakeAuthResponse({super.user, super.session});
}

class FakeUser extends User {
  FakeUser({required super.id, required super.email})
      : super(
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-11-20T00:00:00.000Z',
        );
}

class FakeSession extends Session {
  FakeSession({required super.user})
      : super(
          accessToken: 'fake-token',
          tokenType: 'bearer',
        );
}

class MockAuthRepository extends AuthRepository {
  User? mockUser;
  bool throwEmailTaken = false;
  bool throwInvalidCredentials = false;
  bool throwGeneralNetworkError = false;

  @override
  User? get currentUser => mockUser;

  @override
  bool get isAuthenticated => mockUser != null;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (throwEmailTaken) {
      throw const AuthException('Email sudah digunakan');
    }
    if (throwGeneralNetworkError) {
      throw Exception('Network error');
    }
    final user = FakeUser(id: 'user-123', email: email);
    mockUser = user;
    return FakeAuthResponse(user: user, session: FakeSession(user: user));
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (throwInvalidCredentials) {
      throw const AuthException('Email atau password salah');
    }
    if (throwGeneralNetworkError) {
      throw Exception('Network error');
    }
    final user = FakeUser(id: 'user-123', email: email);
    mockUser = user;
    return FakeAuthResponse(user: user, session: FakeSession(user: user));
  }

  @override
  Future<void> signOut() async {
    mockUser = null;
  }
}

void main() {
  group('AuthProvider Unit Tests (US05)', () {
    test('US05-AC1: register berhasil mendaftarkan akun dan langsung masuk ke status authenticated', () async {
      final repo = MockAuthRepository();
      final provider = AuthProvider(repository: repo);

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.isAuthenticated, false);

      final success = await provider.register(
        email: 'pemilik@kosfinder.com',
        password: 'password123',
      );

      expect(success, true);
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.isAuthenticated, true);
      expect(provider.user?.email, 'pemilik@kosfinder.com');
      expect(provider.errorMessage, isNull);
    });

    test('US05-AC2: register gagal jika email sudah digunakan dan menampilkan pesan sesuai AC', () async {
      final repo = MockAuthRepository()..throwEmailTaken = true;
      final provider = AuthProvider(repository: repo);

      final success = await provider.register(
        email: 'sudahada@kosfinder.com',
        password: 'password123',
      );

      expect(success, false);
      expect(provider.status, AuthStatus.error);
      expect(provider.isAuthenticated, false);
      expect(provider.errorMessage, 'Email sudah digunakan');
    });

    test('US05-AC3: login berhasil dengan kredensial benar', () async {
      final repo = MockAuthRepository();
      final provider = AuthProvider(repository: repo);

      final success = await provider.login(
        email: 'pemilik@kosfinder.com',
        password: 'password123',
      );

      expect(success, true);
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.isAuthenticated, true);
      expect(provider.user?.id, 'user-123');
    });

    test('US05-AC4: login gagal dengan password salah dan menampilkan pesan error sesuai AC', () async {
      final repo = MockAuthRepository()..throwInvalidCredentials = true;
      final provider = AuthProvider(repository: repo);

      final success = await provider.login(
        email: 'pemilik@kosfinder.com',
        password: 'passwordsalah',
      );

      expect(success, false);
      expect(provider.status, AuthStatus.error);
      expect(provider.isAuthenticated, false);
      expect(provider.errorMessage, 'Email atau password salah');
    });

    test('logout berhasil mengosongkan user dan mengembalikan status ke unauthenticated', () async {
      final repo = MockAuthRepository()..mockUser = FakeUser(id: 'user-1', email: 'owner@test.com');
      final provider = AuthProvider(repository: repo);

      expect(provider.isAuthenticated, true);

      await provider.logout();

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
    });
  });
}
