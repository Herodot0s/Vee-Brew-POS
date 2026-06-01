import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/widgets/product_grid.dart';
import 'package:veebrew/providers/database_provider.dart';
import 'package:veebrew/database/drift_database.dart';

void main() {
  testWidgets('ProductGrid filters products by category', (tester) async {
    final db = AppDatabase.memory();
    await db.seedInitialData();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProductGrid(),
          ),
        ),
      ),
    );

    // Wait for the stream to emit
    await tester.pumpAndSettle();

    // Initial default category is 'milk_tea'
    expect(find.text('Wintermelon Milk Tea'), findsOneWidget);
    expect(find.text('Okinawa Milk Tea'), findsOneWidget);
    expect(find.text('BBQ Fries'), findsNothing);

    await db.close();
  });
}
