import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/owner_kos_repository.dart';

class MockOwnerKosRepository extends OwnerKosRepository {
  final String activeOwnerId;
  final List<KosModel> database;
  bool throwNetworkError = false;

  MockOwnerKosRepository({
    required this.activeOwnerId,
    required this.database,
  });

  @override
  Future<List<KosModel>> getMyKosList() async {
    if (throwNetworkError) throw Exception('Connection error');
    // Isolasi data: hanya kos dengan owner_id milik akun login
    return database.where((k) => k.ownerId == activeOwnerId).toList();
  }

  @override
  Future<KosModel> insertKos(KosModel kos) async {
    if (throwNetworkError) throw Exception('Connection error');
    final newKos = kos.copyWith(
      id: 'kos-${database.length + 1}',
      ownerId: activeOwnerId,
    );
    database.insert(0, newKos);
    return newKos;
  }

  @override
  Future<KosModel?> updateKos(KosModel kos) async {
    if (throwNetworkError) throw Exception('Connection error');
    final index = database.indexWhere((k) => k.id == kos.id);
    if (index == -1) return null;

    // Proteksi RLS: Hanya update jika pemilik data sama dengan activeOwnerId
    if (database[index].ownerId != activeOwnerId) {
      // Data tidak berubah
      return null;
    }

    final updated = kos.copyWith(ownerId: activeOwnerId);
    database[index] = updated;
    return updated;
  }

  @override
  Future<bool> deleteKos(String kosId) async {
    if (throwNetworkError) throw Exception('Connection error');
    final index = database.indexWhere((k) => k.id == kosId);
    if (index == -1) return false;

    // Proteksi RLS: Hanya delete jika pemilik data sama
    if (database[index].ownerId != activeOwnerId) {
      return false;
    }

    database.removeAt(index);
    return true;
  }

  @override
  Future<KosModel?> updateAvailability(String kosId, bool isAvailable) async {
    if (throwNetworkError) throw Exception('Connection error');
    final index = database.indexWhere((k) => k.id == kosId);
    if (index == -1) return null;

    if (database[index].ownerId != activeOwnerId) {
      return null;
    }

    final updated = database[index].copyWith(isAvailable: isAvailable);
    database[index] = updated;
    return updated;
  }
}

void main() {
  group('OwnerKosProvider Unit Tests (US06, US07, US08)', () {
    late List<KosModel> sharedDb;

    setUp(() {
      sharedDb = [
        KosModel(
          id: 'kos-1',
          ownerId: 'owner-A',
          name: 'Kos Milik Pemilik A',
          address: 'Jl. Pemilik A No. 1',
          pricePerMonth: 800000,
          type: 'putra',
          facilities: const ['WiFi'],
          description: 'Kos A',
          availableRooms: 2,
          whatsappNumber: '08111',
          isAvailable: true,
        ),
        KosModel(
          id: 'kos-2',
          ownerId: 'owner-B',
          name: 'Kos Milik Pemilik B',
          address: 'Jl. Pemilik B No. 2',
          pricePerMonth: 900000,
          type: 'putri',
          facilities: const ['AC'],
          description: 'Kos B',
          availableRooms: 1,
          whatsappNumber: '08222',
          isAvailable: true,
        ),
      ];
    });

    test('Isolasi State: fetchMyKos hanya mengambil kos milik owner aktif', () async {
      final repo = MockOwnerKosRepository(activeOwnerId: 'owner-A', database: sharedDb);
      final provider = OwnerKosProvider(repository: repo);

      await provider.fetchMyKos();

      expect(provider.myKosList.length, 1);
      expect(provider.myKosList.first.name, 'Kos Milik Pemilik A');
      expect(provider.myKosList.first.ownerId, 'owner-A');
    });

    test('US06-AC1: addKos berhasil menambahkan kos baru dengan owner_id aktif', () async {
      final repo = MockOwnerKosRepository(activeOwnerId: 'owner-A', database: sharedDb);
      final provider = OwnerKosProvider(repository: repo);

      await provider.fetchMyKos();

      const newKosInput = KosModel(
        id: '',
        ownerId: '',
        name: 'Kos Tambahan A',
        address: 'Jl. Baru No. 3',
        pricePerMonth: 700000,
        type: 'campur',
        facilities: ['WiFi', 'parkir'],
        description: 'Baru buka',
        availableRooms: 5,
        whatsappNumber: '08113',
      );

      final success = await provider.addKos(newKosInput);

      expect(success, true);
      expect(provider.myKosList.length, 2);
      expect(provider.myKosList.first.name, 'Kos Tambahan A');
      expect(provider.myKosList.first.ownerId, 'owner-A');
    });

    test('US07-AC1: Pemilik A mencoba mengubah kos milik Pemilik B -> perubahan ditolak dan data tidak berubah', () async {
      // Login sebagai Pemilik A
      final repo = MockOwnerKosRepository(activeOwnerId: 'owner-A', database: sharedDb);
      final provider = OwnerKosProvider(repository: repo);

      await provider.fetchMyKos();

      // Coba ubah kos-2 (milik Pemilik B)
      final maliciousEdit = sharedDb.firstWhere((k) => k.id == 'kos-2').copyWith(
            name: 'Nama Kos B Diretas',
            pricePerMonth: 100000,
          );

      final success = await provider.editKos(maliciousEdit);

      // Mutasi gagal
      expect(success, false);
      expect(provider.errorMessage, contains('Perubahan ditolak'));

      // Verifikasi di database: data milik Pemilik B TIDAK BERUBAH
      final kosBInDb = sharedDb.firstWhere((k) => k.id == 'kos-2');
      expect(kosBInDb.name, 'Kos Milik Pemilik B');
      expect(kosBInDb.pricePerMonth, 900000);
    });

    test('US07-AC1: Pemilik A mencoba menghapus kos milik Pemilik B -> penghapusan ditolak dan data tidak berubah', () async {
      final repo = MockOwnerKosRepository(activeOwnerId: 'owner-A', database: sharedDb);
      final provider = OwnerKosProvider(repository: repo);

      final success = await provider.removeKos('kos-2');

      expect(success, false);
      expect(provider.errorMessage, contains('Penghapusan ditolak'));

      // Kos B tetap ada di DB
      expect(sharedDb.any((k) => k.id == 'kos-2'), true);
    });

    test('US07-AC2: Pemilik A menghapus kos miliknya sendiri -> kos terhapus permanen', () async {
      final repo = MockOwnerKosRepository(activeOwnerId: 'owner-A', database: sharedDb);
      final provider = OwnerKosProvider(repository: repo);

      await provider.fetchMyKos();
      expect(provider.myKosList.length, 1);

      final success = await provider.removeKos('kos-1');

      expect(success, true);
      expect(provider.myKosList, isEmpty);
      expect(sharedDb.any((k) => k.id == 'kos-1'), false);
    });

    test('US08-AC1 & AC2: toggleAvailability mengubah status dan menangani kegagalan koneksi', () async {
      final repo = MockOwnerKosRepository(activeOwnerId: 'owner-A', database: sharedDb);
      final provider = OwnerKosProvider(repository: repo);

      await provider.fetchMyKos();
      expect(provider.myKosList.first.isAvailable, true);

      // Ubah dari Tersedia ke Penuh (US08-AC1)
      final success = await provider.toggleAvailability('kos-1', true);
      expect(success, true);
      expect(provider.myKosList.first.isAvailable, false);

      // Simulasi koneksi terputus saat toggle (US08-AC2)
      repo.throwNetworkError = true;
      final fail = await provider.toggleAvailability('kos-1', false);
      expect(fail, false);
      expect(provider.errorMessage, contains('Gagal mengubah status'));
      // Status tidak berubah
      expect(provider.myKosList.first.isAvailable, false);
    });
  });
}
