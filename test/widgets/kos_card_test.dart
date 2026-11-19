import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/widgets/kos_card.dart';

void main() {
  group('KosCard Widget Tests (US01-AC1)', () {
    testWidgets('KosCard menampilkan nama, alamat, jenis, harga, dan teks status Tersedia', (WidgetTester tester) async {
      final kos = KosModel(
        id: 'kos-1',
        ownerId: 'owner-1',
        name: 'Kos Sejahtera Indah',
        address: 'Jl. Merdeka No. 12',
        pricePerMonth: 750000,
        type: 'putra',
        facilities: const ['WiFi', 'AC'],
        description: 'Kos asri',
        availableRooms: 3,
        whatsappNumber: '08123456789',
        isAvailable: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KosCard(kos: kos),
          ),
        ),
      );

      expect(find.text('Kos Sejahtera Indah'), findsOneWidget);
      expect(find.text('Jl. Merdeka No. 12'), findsOneWidget);
      expect(find.text('Kos Putra'), findsOneWidget);
      expect(find.textContaining('750.000'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);
    });

    testWidgets('KosCard menampilkan teks status Penuh saat isAvailable = false', (WidgetTester tester) async {
      final kos = KosModel(
        id: 'kos-2',
        ownerId: 'owner-2',
        name: 'Kos Melati Cantik',
        address: 'Jl. Kenanga No. 5',
        pricePerMonth: 500000,
        type: 'putri',
        facilities: const ['WiFi'],
        description: 'Kos putri aman',
        availableRooms: 0,
        whatsappNumber: '08123456788',
        isAvailable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KosCard(kos: kos),
          ),
        ),
      );

      expect(find.text('Kos Melati Cantik'), findsOneWidget);
      expect(find.text('Penuh'), findsOneWidget);
    });
  });
}
