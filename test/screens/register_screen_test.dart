import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/auth/register_screen.dart';
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

class MockRegisterRepo extends AuthRepository {
  bool throwEmailTaken = false;

  @override
  User? get currentUser => null;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (throwEmailTaken) {
      throw const AuthException('Email sudah digunakan');
    }
    final user = FakeUser(id: 'owner-new', email: email);
    return AuthResponse(user: user, session: FakeSession(user: user));
  }
}

void main() {
  group('RegisterScreen Widget Tests (US05)', () {
    testWidgets('Validasi form: password minimal 8 karakter dan konfirmasi cocok', (WidgetTester tester) async {
      final repo = MockRegisterRepo();
      final provider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'pemilik@kos.com');
      await tester.enterText(textFields.at(1), '12345'); // < 8 karakter
      await tester.enterText(textFields.at(2), '12345678');

      final registerButton = find.widgetWithText(ElevatedButton, 'Daftar');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 8 karakter'), findsOneWidget);

      // Perbaiki password tetapi konfirmasi beda
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'passwordBerbeda');

      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Password konfirmasi tidak cocok'), findsOneWidget);
    });

    testWidgets('US05-AC2: Pendaftaran dengan email yang sudah digunakan menampilkan SnackBar error', (WidgetTester tester) async {
      final repo = MockRegisterRepo()..throwEmailTaken = true;
      final provider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'duplikat@kos.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'password123');

      final registerButton = find.widgetWithText(ElevatedButton, 'Daftar');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Email sudah digunakan'), findsOneWidget);
    });

    testWidgets('US05-AC1: Pendaftaran sukses menampilkan SnackBar sukses', (WidgetTester tester) async {
      final repo = MockRegisterRepo();
      final provider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'baru@kos.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'password123');

      final registerButton = find.widgetWithText(ElevatedButton, 'Daftar');
      await tester.tap(registerButton);
      await tester.pump();

      expect(find.text('Pendaftaran berhasil! Akun pemilik aktif.'), findsOneWidget);
    });
  });
}
