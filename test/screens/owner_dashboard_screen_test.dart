import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/owner_kos_repository.dart';
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

class MockAuthRepo extends AuthRepository {
  final User? activeUser;
  MockAuthRepo({this.activeUser});

  @override
  User? get currentUser => activeUser;
  @override
  bool get isAuthenticated => activeUser != null;
  @override
  Future<void> signOut() async {}
}

class MockOwnerRepo extends OwnerKosRepository {
  final List<KosModel> data;
  MockOwnerRepo({required this.data});

  @override
  Future<List<KosModel>> getMyKosList() async => data;
}

void main() {
  group('OwnerDashboardScreen Widget Tests (T11)', () {
    final sampleUser = FakeUser(id: 'owner-1', email: 'pemilik@kosfinder.com');

    final myKosList = [
      KosModel(
        id: 'kos-1',
        ownerId: 'owner-1',
        name: 'Kos Melati Indah',
        address: 'Jl. Melati No. 5',
        pricePerMonth: 850000,
        type: 'putri',
        facilities: const ['WiFi', 'AC'],
        description: 'Kos putri aman',
        availableRooms: 3,
        whatsappNumber: '08123456789',
        isAvailable: true,
      ),
    ];

    testWidgets('Menampilkan email pemilik aktif, daftar kos miliknya, tombol tambah, dan opsi keluar', (WidgetTester tester) async {
      final authProvider = AuthProvider(repository: MockAuthRepo(activeUser: sampleUser));
      final ownerKosProvider = OwnerKosProvider(repository: MockOwnerRepo(data: myKosList));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: ownerKosProvider),
          ],
          child: const MaterialApp(home: OwnerDashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Banner email pemilik
      expect(find.text('pemilik@kosfinder.com'), findsOneWidget);

      // Kartu kos milik sendiri
      expect(find.text('Kos Melati Indah'), findsOneWidget);
      expect(find.text('Jl. Melati No. 5'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.text('3 Kamar Kosong'), findsOneWidget);

      // Opsi tombol aksi navigasi
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
      expect(find.text('Tambah Kos'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('Menampilkan pesan saat pemilik belum memiliki kos', (WidgetTester tester) async {
      final authProvider = AuthProvider(repository: MockAuthRepo(activeUser: sampleUser));
      final ownerKosProvider = OwnerKosProvider(repository: MockOwnerRepo(data: []));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: ownerKosProvider),
          ],
          child: const MaterialApp(home: OwnerDashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Anda belum memiliki kos terdaftar'), findsOneWidget);
    });
  });
}
