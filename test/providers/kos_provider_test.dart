import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockSuccessKosRepository extends KosRepository {
  final List<KosModel> dummyList;

  MockSuccessKosRepository(this.dummyList);

  @override
  Future<List<KosModel>> getPublicKosList() async {
    return dummyList;
  }
}

class MockErrorKosRepository extends KosRepository {
  @override
  Future<List<KosModel>> getPublicKosList() async {
    throw Exception('Connection error');
  }
}

void main() {
  group('KosProvider Unit Tests (US01)', () {
    final sampleKosList = [
      KosModel(
        id: 'kos-2',
        ownerId: 'owner-1',
        name: 'Kos B (Terbaru)',
        address: 'Jl. Melati',
        pricePerMonth: 900000,
        type: 'putra',
        facilities: const ['WiFi'],
        description: 'Baru dibuat',
        availableRooms: 2,
        whatsappNumber: '08123',
        createdAt: DateTime.parse('2026-11-19T12:00:00Z'),
      ),
      KosModel(
        id: 'kos-1',
        ownerId: 'owner-1',
        name: 'Kos A (Terdahulu)',
        address: 'Jl. Mawar',
        pricePerMonth: 800000,
        type: 'putri',
        facilities: const ['AC'],
        description: 'Kos lama',
        availableRooms: 1,
        whatsappNumber: '08124',
        createdAt: DateTime.parse('2026-11-19T10:00:00Z'),
      ),
    ];

    test('US01-AC1 & AC2: fetchPublicKos berhasil memuat daftar kos', () async {
      final repository = MockSuccessKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      expect(provider.state, KosState.initial);
      expect(provider.kosList, isEmpty);

      final future = provider.fetchPublicKos();
      expect(provider.isLoading, true);

      await future;

      expect(provider.state, KosState.loaded);
      expect(provider.kosList.length, 2);
      expect(provider.kosList.first.name, 'Kos B (Terbaru)');
      expect(provider.isEmpty, false);
      expect(provider.hasError, false);
    });

    test('US01-AC3: fetchPublicKos menangani kondisi database kosong', () async {
      final repository = MockSuccessKosRepository([]);
      final provider = KosProvider(repository: repository);

      await provider.fetchPublicKos();

      expect(provider.state, KosState.loaded);
      expect(provider.kosList, isEmpty);
      expect(provider.isEmpty, true);
    });

    test('US01-AC4: fetchPublicKos menangani kegagalan koneksi jaringan dengan error yang ramah', () async {
      final repository = MockErrorKosRepository();
      final provider = KosProvider(repository: repository);

      await provider.fetchPublicKos();

      expect(provider.state, KosState.error);
      expect(provider.hasError, true);
      expect(provider.errorMessage, contains('Gagal memuat data kos'));
      expect(provider.kosList, isEmpty);
    });
  });
}
