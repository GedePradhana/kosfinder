import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockSearchKosRepository extends KosRepository {
  final List<KosModel> allData;

  MockSearchKosRepository(this.allData);

  @override
  Future<List<KosModel>> getPublicKosList({String? searchQuery}) async {
    if (searchQuery == null || searchQuery.trim().isEmpty) {
      return allData;
    }
    final q = searchQuery.toLowerCase().trim();
    return allData.where((kos) {
      final nameMatches = kos.name.toLowerCase().contains(q);
      final addressMatches = kos.address.toLowerCase().contains(q);
      return nameMatches || addressMatches;
    }).toList();
  }
}

class MockErrorKosRepository extends KosRepository {
  @override
  Future<List<KosModel>> getPublicKosList({String? searchQuery}) async {
    throw Exception('Connection error');
  }
}

void main() {
  group('KosProvider Unit Tests (US01 & US03)', () {
    final sampleKosList = [
      KosModel(
        id: 'kos-1',
        ownerId: 'owner-1',
        name: 'Kos Tembalang Asri',
        address: 'Jl. Prof Soedarto, Tembalang',
        pricePerMonth: 850000,
        type: 'putra',
        facilities: const ['WiFi'],
        description: 'Dekat Undip',
        availableRooms: 2,
        whatsappNumber: '08123',
        createdAt: DateTime.parse('2026-11-19T12:00:00Z'),
      ),
      KosModel(
        id: 'kos-2',
        ownerId: 'owner-2',
        name: 'Kos Mawar Bahagia',
        address: 'Jl. Banyumanik Indah',
        pricePerMonth: 900000,
        type: 'putri',
        facilities: const ['AC'],
        description: 'Kos putri nyaman',
        availableRooms: 1,
        whatsappNumber: '08124',
        createdAt: DateTime.parse('2026-11-19T10:00:00Z'),
      ),
    ];

    test('US01-AC1: fetchPublicKos berhasil memuat seluruh daftar kos', () async {
      final repository = MockSearchKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      await provider.fetchPublicKos();

      expect(provider.state, KosState.loaded);
      expect(provider.kosList.length, 2);
      expect(provider.isSearching, false);
    });

    test('US03-AC1: search berhasil menyaring kos berdasarkan nama atau area', () async {
      final repository = MockSearchKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      await provider.search('Tembalang');

      expect(provider.state, KosState.loaded);
      expect(provider.isSearching, true);
      expect(provider.searchQuery, 'Tembalang');
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Tembalang Asri');
    });

    test('US03-AC2: search menghasilkan daftar kosong saat kata kunci tidak cocok', () async {
      final repository = MockSearchKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      await provider.search('LokasiTidakAda');

      expect(provider.state, KosState.loaded);
      expect(provider.isSearching, true);
      expect(provider.isEmpty, true);
      expect(provider.kosList, isEmpty);
    });

    test('clearSearch mengembalikan seluruh daftar kos awal', () async {
      final repository = MockSearchKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      await provider.search('Tembalang');
      expect(provider.kosList.length, 1);

      await provider.clearSearch();
      expect(provider.isSearching, false);
      expect(provider.searchQuery, '');
      expect(provider.kosList.length, 2);
    });
  });
}
