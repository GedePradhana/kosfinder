import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';

void main() {
  testWidgets('Aplikasi merender HomeScreenPlaceholder dan tombol navigasi About', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('KosFinder'), findsWidgets);
    expect(find.byIcon(Icons.info_outline), findsWidgets);
  });
}
