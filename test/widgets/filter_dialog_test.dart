import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/widgets/filter_dialog.dart';

void main() {
  group('FilterDialog Widget Tests (US04)', () {
    testWidgets('US04-AC1: Memasukkan min & maks yang valid dan menekan Terapkan memanggil onApply', (WidgetTester tester) async {
      int? receivedMin;
      int? receivedMax;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterDialog(
              onApply: (min, max) {
                receivedMin = min;
                receivedMax = max;
              },
              onReset: () {},
            ),
          ),
        ),
      );

      // Cari TextField pertama (min) dan kedua (max)
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.at(0), '500000');
      await tester.enterText(textFields.at(1), '1000000');

      // Tekan tombol Terapkan
      final applyButton = find.text('Terapkan');
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      expect(receivedMin, 500000);
      expect(receivedMax, 1000000);
    });

    testWidgets('US04-AC2: Memasukkan min > max memunculkan pesan validasi error dan tidak memanggil onApply', (WidgetTester tester) async {
      bool onApplyCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterDialog(
              onApply: (min, max) {
                onApplyCalled = true;
              },
              onReset: () {},
            ),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      // Min 1.000.000 > Max 500.000 (US04-AC2)
      await tester.enterText(textFields.at(0), '1000000');
      await tester.enterText(textFields.at(1), '500000');

      final applyButton = find.text('Terapkan');
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Pesan validasi tampil
      expect(find.text('Harga minimum tidak boleh lebih besar dari harga maksimum'), findsOneWidget);
      expect(onApplyCalled, false);
    });

    testWidgets('Menekan tombol Reset memanggil onReset', (WidgetTester tester) async {
      bool onResetCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterDialog(
              initialMinPrice: 500000,
              initialMaxPrice: 1000000,
              onApply: (min, max) {},
              onReset: () {
                onResetCalled = true;
              },
            ),
          ),
        ),
      );

      final resetButton = find.text('Reset');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      expect(onResetCalled, true);
    });
  });
}
