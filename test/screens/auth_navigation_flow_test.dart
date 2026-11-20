import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/repositories/owner_kos_repository.dart';
import 'package:kosfinder/screens/home_screen.dart';
import 'package:kosfinder/screens/owner/owner_dashboard_screen.dart';
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
  User? _user;

  @override
  User? get currentUser => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _user = FakeUser(id: 'owner-1', email: email);
    return AuthResponse(user: _user, session: FakeSession(user: _user!));
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

class MockKosRepo extends KosRepository {
  @override
  Future<List<KosModel>> getPublicKosList({String? searchQuery}) async => [];
}

class MockOwnerKosRepo extends OwnerKosRepository {
  @override
  Future<List<KosModel>> getMyKosList() async => [];
}

void main() {
  group('Auth Navigation Flow Tests (Login -> Dashboard -> Back to Home -> Area Pemilik -> Logout)', () {
    testWidgets('Alur lengkap: Login -> Masuk Dashboard -> Kembali ke Home -> Tekan Area Pemilik langsung ke Dashboard -> Logout', (WidgetTester tester) async {
      final authRepo = MockAuthRepo();
      final authProvider = AuthProvider(repository: authRepo);
      final kosProvider = KosProvider(repository: MockKosRepo());
      final ownerKosProvider = OwnerKosProvider(repository: MockOwnerKosRepo());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<KosProvider>.value(value: kosProvider),
            ChangeNotifierProvider<OwnerKosProvider>.value(value: ownerKosProvider),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Awalnya belum login, tap ikon Area Pemilik di AppBar
      final areaPemilikIcon = find.byTooltip('Area Pemilik');
      expect(areaPemilikIcon, findsOneWidget);
      await tester.tap(areaPemilikIcon);
      await tester.pumpAndSettle();

      // Layar Login Pemilik Kos tampil
      expect(find.text('Login Pemilik Kos'), findsOneWidget);

      // 2. Masukkan kredensial dan tekan Login
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'pemilik@kos.com');
      await tester.enterText(textFields.at(1), 'password123');

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Sesuai perbaikan: Navigator.pushReplacement langsung membuka OwnerDashboardScreen
      expect(find.byType(OwnerDashboardScreen), findsOneWidget);
      expect(find.text('Dashboard Pemilik'), findsOneWidget);
      expect(find.text('pemilik@kos.com'), findsOneWidget);

      // 3. Tekan tombol back di AppBar untuk kembali ke HomeScreen
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Sekarang berada di HomeScreen
      expect(find.text('KosFinder'), findsOneWidget);
      expect(authProvider.isAuthenticated, isTrue);

      // 4. Tekan tombol Area Pemilik lagi saat session masih aktif
      await tester.tap(areaPemilikIcon);
      await tester.pumpAndSettle();

      // Langsung masuk ke OwnerDashboardScreen tanpa melewati form login!
      expect(find.byType(OwnerDashboardScreen), findsOneWidget);
      expect(find.text('Dashboard Pemilik'), findsOneWidget);

      // 5. Lakukan Logout dari Dashboard
      final logoutButton = find.byIcon(Icons.logout);
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Dialog konfirmasi keluar muncul
      expect(find.text('Konfirmasi Keluar'), findsOneWidget);
      final confirmLogoutBtn = find.widgetWithText(ElevatedButton, 'Keluar');
      await tester.tap(confirmLogoutBtn);
      await tester.pumpAndSettle();

      // Kembali ke HomeScreen dan state ter-logout
      expect(find.text('KosFinder'), findsOneWidget);
      expect(authProvider.isAuthenticated, isFalse);

      // 6. Verifikasi setelah logout jika Area Pemilik ditekan lagi, akan kembali ke LoginScreen
      await tester.tap(areaPemilikIcon);
      await tester.pumpAndSettle();
      expect(find.text('Login Pemilik Kos'), findsOneWidget);
    });
  });
}
