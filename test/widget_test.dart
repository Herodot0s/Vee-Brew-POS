import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/main.dart';
import 'package:veebrew/providers/database_provider.dart';
import 'package:veebrew/database/drift_database.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final db = AppDatabase.memory();
    await db.seedInitialData();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const VeebrewApp(),
      ),
    );

    // Wait for initial database stream emits
    await tester.pumpAndSettle();

    // Verify that the POSScreen with VEEBREW sidebar title is shown.
    expect(find.text('VEEBREW'), findsOneWidget);

    await db.close();
  });
}
