import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/owner_kos_repository.dart';
import 'package:kosfinder/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class MockAuthRepo extends AuthRepository {
  bool throwInvalidCredentials = false;

  @override
  User? get currentUser => null;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (throwInvalidCredentials) {
      throw const AuthException('Email atau password salah');
    }
    final user = FakeUser(id: 'owner-1', email: email);
    return AuthResponse(user: user, session: FakeSession(user: user));
  }
}

class MockOwnerKosRepo extends OwnerKosRepository {
  @override
  Future<List<KosModel>> getMyKosList() async => [];
}

void main() {
  group('LoginScreen Widget Tests (US05)', () {
    testWidgets('Validasi form: menampilkan error jika email/password kosong atau password < 8 karakter', (WidgetTester tester) async {
      final repo = MockAuthRepo();
      final provider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      // Tekan tombol Login langsung saat form kosong
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);

      // Masukkan password < 8 karakter
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'pemilik@kos.com');
      await tester.enterText(textFields.at(1), '12345');

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    });

    testWidgets('US05-AC4: Login gagal dengan password salah memunculkan SnackBar error', (WidgetTester tester) async {
      final repo = MockAuthRepo()..throwInvalidCredentials = true;
      final provider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'pemilik@kos.com');
      await tester.enterText(textFields.at(1), 'passwordsalah');

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Email atau password salah'), findsOneWidget);
    });

    testWidgets('US05-AC3: Login berhasil memunculkan SnackBar sukses', (WidgetTester tester) async {
      final repo = MockAuthRepo();
      final provider = AuthProvider(repository: repo);
      final ownerRepo = MockOwnerKosRepo();
      final ownerProvider = OwnerKosProvider(repository: ownerRepo);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider.value(value: ownerProvider),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'pemilik@kos.com');
      await tester.enterText(textFields.at(1), 'password123');

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Login berhasil! Selamat datang.'), findsOneWidget);
    });
  });
}
