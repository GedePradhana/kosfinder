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

    testWidgets('T15: DetailKosScreen menampilkan badge berwarna untuk status Tersedia', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetailKosScreen(
            kosId: 'kos-101',
            initialKos: sampleKos, // isAvailable: true
          ),
        ),
      );

      final textAvailable = find.text('Tersedia');
      expect(textAvailable, findsOneWidget);
      final badgeAvailable = tester.widget<Container>(
        find.ancestor(of: textAvailable, matching: find.byType(Container)).first,
      );
      final decorAvailable = badgeAvailable.decoration as BoxDecoration;
      expect(decorAvailable.color, Colors.green.shade50);
    });

    testWidgets('T15: DetailKosScreen menampilkan badge berwarna untuk status Penuh', (WidgetTester tester) async {
      final fullKos = sampleKos.copyWith(id: 'kos-102', isAvailable: false);
      await tester.pumpWidget(
        MaterialApp(
          home: DetailKosScreen(
            kosId: 'kos-102',
            initialKos: fullKos,
          ),
        ),
      );

      final textFull = find.text('Penuh');
      expect(textFull, findsOneWidget);
      final badgeFull = tester.widget<Container>(
        find.ancestor(of: textFull, matching: find.byType(Container)).first,
      );
      final decorFull = badgeFull.decoration as BoxDecoration;
      expect(decorFull.color, Colors.red.shade50);
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

    testWidgets('NFR Privasi: DetailKosScreen mengambil nomor WhatsApp jika initialKos tidak memiliki whatsappNumber (dari daftar publik)', (WidgetTester tester) async {
      // Kos dari daftar publik: whatsappNumber kosong
      final publicKos = sampleKos.copyWith(whatsappNumber: '');
      final repo = MockDetailSuccessRepo(sampleKos); // Detail lengkap memiliki nomor WA

      await tester.pumpWidget(
        MaterialApp(
          home: DetailKosScreen(
            kosId: 'kos-101',
            initialKos: publicKos,
            repository: repo,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Memastikan nomor kontak WhatsApp pemilik dan tombol WhatsApp tetap tampil
      expect(find.text('081234567890'), findsOneWidget);
      expect(find.text('Hubungi via WhatsApp'), findsOneWidget);
    });
  });
}
