import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockPriceFilterKosRepository extends KosRepository {
  final List<KosModel> allData;

  MockPriceFilterKosRepository(this.allData);

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

void main() {
  group('KosProvider Unit Tests (US01, US03, & US04)', () {
    final sampleKosList = [
      KosModel(
        id: 'kos-1',
        ownerId: 'owner-1',
        name: 'Kos Murah',
        address: 'Jl. Merdeka',
        pricePerMonth: 450000,
        type: 'campur',
        facilities: const ['WiFi'],
        description: 'Kos murah',
        availableRooms: 1,
        whatsappNumber: '081',
      ),
      KosModel(
        id: 'kos-2',
        ownerId: 'owner-1',
        name: 'Kos Sedang',
        address: 'Jl. Melati',
        pricePerMonth: 800000,
        type: 'putra',
        facilities: const ['WiFi', 'AC'],
        description: 'Kos menengah',
        availableRooms: 2,
        whatsappNumber: '082',
      ),
      KosModel(
        id: 'kos-3',
        ownerId: 'owner-2',
        name: 'Kos Eksklusif',
        address: 'Jl. Mawar',
        pricePerMonth: 1500000,
        type: 'putri',
        facilities: const ['WiFi', 'AC', 'kamar mandi dalam'],
        description: 'Kos nyaman',
        availableRooms: 3,
        whatsappNumber: '083',
      ),
    ];

    test('US04-AC1: setPriceFilter menyaring kos dalam rentang min dan maks', () async {
      final repository = MockPriceFilterKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      await provider.fetchPublicKos();
      expect(provider.kosList.length, 3);

      // Filter rentang 500.000 s.d 1.000.000 (US04-AC1)
      provider.setPriceFilter(minPrice: 500000, maxPrice: 1000000);

      expect(provider.isFilteredByPrice, true);
      expect(provider.minPrice, 500000);
      expect(provider.maxPrice, 1000000);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Sedang');
      expect(provider.kosList.first.pricePerMonth, 800000);
    });

    test('US04-AC1: setPriceFilter hanya dengan batas minimum', () async {
      final repository = MockPriceFilterKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      await provider.fetchPublicKos();
      provider.setPriceFilter(minPrice: 800000);

      expect(provider.kosList.length, 2);
      expect(provider.kosList.map((e) => e.name), containsAll(['Kos Sedang', 'Kos Eksklusif']));
    });

    test('US04-AC1: setPriceFilter hanya dengan batas maksimum', () async {
      final repository = MockPriceFilterKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      await provider.fetchPublicKos();
      provider.setPriceFilter(maxPrice: 800000);

      expect(provider.kosList.length, 2);
      expect(provider.kosList.map((e) => e.name), containsAll(['Kos Murah', 'Kos Sedang']));
    });

    test('US04-AC2: setPriceFilter melempar ArgumentError jika min > max', () async {
      final repository = MockPriceFilterKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      await provider.fetchPublicKos();

      expect(
        () => provider.setPriceFilter(minPrice: 1000000, maxPrice: 500000),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Harga minimum tidak boleh lebih besar dari harga maksimum',
        )),
      );
    });

    test('clearPriceFilter mengembalikan daftar kos tanpa filter harga', () async {
      final repository = MockPriceFilterKosRepository(sampleKosList);
      final provider = KosProvider(repository: repository);

      await provider.fetchPublicKos();
      provider.setPriceFilter(minPrice: 500000, maxPrice: 1000000);
      expect(provider.kosList.length, 1);

      provider.clearPriceFilter();
      expect(provider.isFilteredByPrice, false);
      expect(provider.minPrice, isNull);
      expect(provider.maxPrice, isNull);
      expect(provider.kosList.length, 3);
    });
  });
}
