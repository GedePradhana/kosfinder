import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/home_screen.dart';
import 'package:provider/provider.dart';

class MockSuccessRepo extends KosRepository {
  final List<KosModel> data;
  MockSuccessRepo(this.data);

  @override
  Future<List<KosModel>> getPublicKosList() async => data;
}

class MockErrorRepo extends KosRepository {
  @override
  Future<List<KosModel>> getPublicKosList() async => throw Exception('Koneksi internet terputus');
}

void main() {
  group('HomeScreen Widget Tests (US01-AC1..AC4)', () {
    testWidgets('US01-AC1 & AC2: Menampilkan daftar kos dan teks status ketersediaan', (WidgetTester tester) async {
      final sampleList = [
        KosModel(
          id: 'kos-1',
          ownerId: 'owner-1',
          name: 'Kos B (Terbaru)',
          address: 'Jl. Merpati',
          pricePerMonth: 850000,
          type: 'campur',
          facilities: const ['WiFi'],
          description: 'Kos nyaman',
          availableRooms: 2,
          whatsappNumber: '08111',
          isAvailable: true,
          createdAt: DateTime.parse('2026-11-19T10:00:00Z'),
        ),
      ];

      final provider = KosProvider(repository: MockSuccessRepo(sampleList));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Trigger post frame callback
      await tester.pumpAndSettle();

      expect(find.text('Kos B (Terbaru)'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.textContaining('850.000'), findsOneWidget);
    });

    testWidgets('US01-AC3: Menampilkan pesan "Belum ada kos yang terdaftar" saat DB kosong', (WidgetTester tester) async {
      final provider = KosProvider(repository: MockSuccessRepo([]));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Belum ada kos yang terdaftar'), findsOneWidget);
    });

    testWidgets('US01-AC4: Menampilkan pesan error dan tombol "Coba lagi" saat koneksi gagal', (WidgetTester tester) async {
      final provider = KosProvider(repository: MockErrorRepo());

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat data kos. Silakan periksa koneksi internet Anda.'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
