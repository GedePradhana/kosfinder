import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockTestRepo extends KosRepository {
  @override
  Future<List<KosModel>> getPublicKosList({String? searchQuery}) async => [];
}

void main() {
  testWidgets('Aplikasi merender HomeScreen dengan judul KosFinder dan ikon About', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(kosRepository: MockTestRepo()));
    await tester.pumpAndSettle();

    expect(find.text('KosFinder'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });
}
