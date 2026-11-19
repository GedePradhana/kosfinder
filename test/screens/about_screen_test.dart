import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/screens/about_screen.dart';

void main() {
  testWidgets('AboutScreen menampilkan nama dan NIM pengembang dengan benar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutScreen(),
      ),
    );

    expect(find.text('Tentang Aplikasi'), findsOneWidget);
    expect(find.text('KosFinder'), findsOneWidget);
    expect(find.text('2415051030 - I Gede Pradhana Subawa Deningrat'), findsOneWidget);
  });
}
