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

// ─── Fake ─────────────────────────────────────────────────────────────────

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

class FakeOwnerKosRepo extends OwnerKosRepository {
  final List<KosModel> initialKosList;
  bool deleteSuccess = true;
  String? lastDeletedId;

  FakeOwnerKosRepo({this.initialKosList = const []});

  @override
  Future<List<KosModel>> getMyKosList() async => List.from(initialKosList);

  @override
  Future<KosModel> insertKos(KosModel kos) async => kos;

  @override
  Future<KosModel?> updateKos(KosModel kos) async => kos;

  @override
  Future<bool> deleteKos(String id) async {
    if (!deleteSuccess) return false;
    lastDeletedId = id;
    return true;
  }

  @override
  Future<KosModel?> updateAvailability(String kosId, bool isAvailable) async => null;
}

// ─── Helper data & widget builder ────────────────────────────────────────────

final _sampleUser = FakeUser(id: 'owner-t13', email: 'owner@kosfinder.com');

final _kosA = KosModel(
  id: 'kos-t13-001',
  ownerId: 'owner-t13',
  name: 'Kos Flamboyan',
  address: 'Jl. Flamboyan No. 1',
  pricePerMonth: 600000,
  type: 'putra',
  facilities: const ['AC', 'WiFi'],
  description: 'Kos dekat kampus.',
  availableRooms: 3,
  whatsappNumber: '081200000001',
  isAvailable: true,
);

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

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OwnerDashboardScreen Delete Tests (T13 / US07-AC2)', () {
    late FakeOwnerKosRepo fakeRepo;
    late OwnerKosProvider ownerProvider;
    late AuthProvider authProvider;

    setUp(() {
      fakeRepo = FakeOwnerKosRepo(initialKosList: [_kosA]);
      ownerProvider = OwnerKosProvider(repository: fakeRepo);
      authProvider = AuthProvider(repository: MockAuthRepo(activeUser: _sampleUser));
    });

    testWidgets('Tombol Hapus dan Edit muncul di card kos pemilik', (tester) async {
      await tester.pumpWidget(buildDashboard(
        ownerProvider: ownerProvider,
        authProvider: authProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hapus'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('US07-AC2: Menekan Hapus menampilkan dialog konfirmasi', (tester) async {
      await tester.pumpWidget(buildDashboard(
        ownerProvider: ownerProvider,
        authProvider: authProvider,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Dialog konfirmasi harus muncul
      expect(find.text('Konfirmasi Hapus'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('US07-AC2: Menekan Batal di dialog tidak menghapus kos', (tester) async {
      await tester.pumpWidget(buildDashboard(
        ownerProvider: ownerProvider,
        authProvider: authProvider,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Repository tidak dipanggil
      expect(fakeRepo.lastDeletedId, isNull);
      // Kos masih tampil
      expect(find.text('Kos Flamboyan'), findsOneWidget);
    });

    testWidgets('US07-AC2: Konfirmasi hapus memanggil removeKos dan SnackBar sukses muncul', (tester) async {
      await tester.pumpWidget(buildDashboard(
        ownerProvider: ownerProvider,
        authProvider: authProvider,
      ));
      await tester.pumpAndSettle();

      // Tap Hapus pada card kos
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Tap tombol Hapus di dalam AlertDialog
      final hapusDialog = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Hapus'),
      );
      await tester.tap(hapusDialog);
      await tester.pumpAndSettle();

      // Repository dipanggil dengan ID yang benar
      expect(fakeRepo.lastDeletedId, 'kos-t13-001');
      // SnackBar keberhasilan muncul
      expect(find.textContaining('berhasil dihapus'), findsOneWidget);
    });
  });
}
