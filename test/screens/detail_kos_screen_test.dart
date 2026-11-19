import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/detail_kos_screen.dart';

class MockDetailSuccessRepo extends KosRepository {
  final KosModel kos;
  MockDetailSuccessRepo(this.kos);

  @override
  Future<KosModel?> getKosDetail(String id) async => kos;
}

class MockDetailErrorRepo extends KosRepository {
  @override
  Future<KosModel?> getKosDetail(String id) async => throw Exception('Koneksi internet terputus');
}

void main() {
  group('DetailKosScreen Widget Tests (US02)', () {
    final sampleKos = KosModel(
      id: 'kos-101',
      ownerId: 'owner-1',
      name: 'Kos Bintang Sembilan',
      address: 'Jl. Melati No. 45, Banyuning',
      pricePerMonth: 950000,
      type: 'campur',
      facilities: const ['WiFi', 'AC', 'kamar mandi dalam', 'parkir', 'dapur bersama'],
      description: 'Kos nyaman dan tenang untuk mahasiswa.',
      availableRooms: 4,
      whatsappNumber: '081234567890',
      isAvailable: true,
    );

    testWidgets('US02-AC1: Menampilkan 9 informasi lengkap kos', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetailKosScreen(
            kosId: 'kos-101',
            initialKos: sampleKos,
          ),
        ),
      );

      // 1. Nama kos
      expect(find.text('Kos Bintang Sembilan'), findsWidgets);
      // 2. Alamat
      expect(find.text('Jl. Melati No. 45, Banyuning'), findsOneWidget);
      // 3. Harga per bulan
      expect(find.textContaining('950.000'), findsOneWidget);
      // 4. Jenis kos
      expect(find.text('Kos Campur'), findsOneWidget);
      // 5. Fasilitas
      expect(find.text('WiFi'), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
      expect(find.text('kamar mandi dalam'), findsOneWidget);
      expect(find.text('parkir'), findsOneWidget);
      expect(find.text('dapur bersama'), findsOneWidget);
      // 6. Deskripsi
      expect(find.text('Kos nyaman dan tenang untuk mahasiswa.'), findsOneWidget);
      // 7. Jumlah kamar
      expect(find.text('4 Kamar'), findsOneWidget);
      // 8. Kontak WhatsApp
      expect(find.text('081234567890'), findsOneWidget);
      // 9. Status ketersediaan
      expect(find.text('Tersedia'), findsOneWidget);

      // Tombol WhatsApp
      expect(find.text('Hubungi via WhatsApp'), findsOneWidget);
    });

    testWidgets('US02-AC1: Menampilkan teks status Penuh saat isAvailable = false', (WidgetTester tester) async {
      final fullKos = sampleKos.copyWith(isAvailable: false, availableRooms: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: DetailKosScreen(
            kosId: 'kos-101',
            initialKos: fullKos,
          ),
        ),
      );

      expect(find.text('Penuh'), findsOneWidget);
      expect(find.text('0 Kamar'), findsOneWidget);
    });

    testWidgets('US02-AC2: Menampilkan pesan error dan tombol Coba lagi saat koneksi gagal', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetailKosScreen(
            kosId: 'kos-101',
            repository: MockDetailErrorRepo(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat detail kos. Silakan periksa koneksi internet Anda.'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
