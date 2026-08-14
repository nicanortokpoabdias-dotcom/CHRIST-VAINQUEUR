// Test de fumée : vérifie que le bandeau du verset du jour s'affiche.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:christ_vainqueur_app/models/daily_verse.dart';
import 'package:christ_vainqueur_app/theme/app_theme.dart';
import 'package:christ_vainqueur_app/widgets/verse_banner.dart';

void main() {
  testWidgets('Le bandeau affiche la référence du verset', (
    WidgetTester tester,
  ) async {
    final verse = DailyVerse.fallback();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: VerseBanner(verse: verse)),
      ),
    );

    expect(find.text('VERSET DU JOUR'), findsOneWidget);
    expect(find.text('— ${verse.reference}'), findsOneWidget);
  });
}
