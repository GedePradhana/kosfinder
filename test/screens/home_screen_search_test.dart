import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/home_screen.dart';
import 'package:provider/provider.dart';

class MockSearchRepo extends KosRepository {
  final List<KosModel> data;
  MockSearchRepo(this.data);

  @override
  Future<List<KosModel>> getPublicKosList({String? searchQuery}) async {
    if (searchQuery == null || searchQuery.trim().isEmpty) return data;
    final q = searchQuery.toLowerCase().trim();
    return data.where((kos) =>
        kos.name.toLowerCase().contains(q) || kos.address.toLowerCase().contains(q)
    ).toList();
  }
}

void main() {
  group('HomeScreen Search Widget Tests (US03)', () {
    final sampleList = [
      KosModel(
        id: 'kos-1',
        ownerId: 'owner-1',
        name: 'Kos Tembalang Jaya',
        address: 'Jl. Banjarsari, Tembalang',
        pricePerMonth: 850000,
        type: 'campur',
        facilities: const ['WiFi'],
        description: 'Kos nyaman',
        availableRooms: 2,
        whatsappNumber: '08111',
        isAvailable: true,
      ),
      KosModel(
        id: 'kos-2',
        ownerId: 'owner-2',
        name: 'Kos Mawar Bahagia',
        address: 'Jl. Pleburan Tengah',
        pricePerMonth: 750000,
        type: 'putri',
        facilities: const ['AC'],
        description: 'Dekat kampus',
        availableRooms: 1,
        whatsappNumber: '08222',
        isAvailable: true,
      ),
    ];

    testWidgets('US03-AC1: Mengetik kata kunci di TextField dan menekan submit menyaring daftar kos', (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSearchRepo(sampleList));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Pastikan kedua kos tampil di awal
      expect(find.text('Kos Tembalang Jaya'), findsOneWidget);
      expect(find.text('Kos Mawar Bahagia'), findsOneWidget);

      // Cari TextField dan ketik "Tembalang"
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Tembalang');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Hanya kos dengan kata Tembalang yang tampil
      expect(find.text('Kos Tembalang Jaya'), findsOneWidget);
      expect(find.text('Kos Mawar Bahagia'), findsNothing);
    });

    testWidgets('US03-AC2: Menampilkan pesan "Kos tidak ditemukan" saat pencarian tidak cocok', (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSearchRepo(sampleList));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'LokasiTidakAda');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Pesan Kos tidak ditemukan tampil
      expect(find.text('Kos tidak ditemukan'), findsOneWidget);
      expect(find.text('Tampilkan semua kos'), findsOneWidget);
    });
  });
}
