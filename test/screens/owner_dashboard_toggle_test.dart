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

class FakeToggleOwnerKosRepo extends OwnerKosRepository {
  final List<KosModel> initialKosList;
  bool updateAvailabilitySuccess = true;
  bool throwError = false;

  FakeToggleOwnerKosRepo({this.initialKosList = const []});

  @override
  Future<List<KosModel>> getMyKosList() async => List.from(initialKosList);

  @override
  Future<KosModel?> updateAvailability(String kosId, bool isAvailable) async {
    if (throwError) throw Exception('Network error');
    if (!updateAvailabilitySuccess) return null;
    final index = initialKosList.indexWhere((k) => k.id == kosId);
    if (index == -1) return null;
    final updated = initialKosList[index].copyWith(isAvailable: isAvailable);
    initialKosList[index] = updated;
    return updated;
  }
}

final _sampleUser = FakeUser(id: 'owner-t14', email: 'owner@kosfinder.com');

Widget buildDashboard({
  required OwnerKosProvider ownerProvider,
  required AuthProvider authProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<OwnerKosProvider>.value(value: ownerProvider),
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
    ],
    child: const MaterialApp(home: OwnerDashboardScreen()),
  );
}

void main() {
  group('OwnerDashboardScreen Toggle Availability Tests (T14 / US08)', () {
    late FakeToggleOwnerKosRepo fakeRepo;
    late OwnerKosProvider ownerProvider;
    late AuthProvider authProvider;
    late KosModel testKos;

    setUp(() {
      testKos = KosModel(
        id: 'kos-toggle-1',
        ownerId: 'owner-t14',
        name: 'Kos Bunga Kenanga',
        address: 'Jl. Kenanga No. 2',
        pricePerMonth: 650000,
        type: 'campur',
        facilities: const ['WiFi', 'Parkir'],
        description: 'Kos strategis',
        availableRooms: 2,
        whatsappNumber: '0812345678',
        isAvailable: true,
      );
      fakeRepo = FakeToggleOwnerKosRepo(initialKosList: [testKos]);
      ownerProvider = OwnerKosProvider(repository: fakeRepo);
      authProvider = AuthProvider(repository: MockAuthRepo(activeUser: _sampleUser));
    });

    testWidgets('US08-AC1: Toggle switch ketersediaan berhasil mengubah status dari Tersedia ke Penuh', (tester) async {
      await tester.pumpWidget(buildDashboard(
        ownerProvider: ownerProvider,
        authProvider: authProvider,
      ));
      await tester.pumpAndSettle();

      // Pastikan switch ada dan bernilai true
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, true);

      // Tap toggle switch
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verifikasi switch bernilai false (Penuh)
      final updatedSwitch = tester.widget<Switch>(switchFinder);
      expect(updatedSwitch.value, false);
      expect(ownerProvider.myKosList.first.isAvailable, false);
    });

    testWidgets('US08-AC2: Gagal mengubah status saat koneksi error, memunculkan SnackBar dan status tidak berubah', (tester) async {
      fakeRepo.throwError = true;

      await tester.pumpWidget(buildDashboard(
        ownerProvider: ownerProvider,
        authProvider: authProvider,
      ));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(tester.widget<Switch>(switchFinder).value, true);

      // Tap toggle switch
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // SnackBar pesan error muncul
      expect(find.textContaining('Gagal mengubah status ketersediaan'), findsOneWidget);

      // Status tetap true (revert/tidak berubah)
      expect(tester.widget<Switch>(switchFinder).value, true);
      expect(ownerProvider.myKosList.first.isAvailable, true);
    });
  });
}
