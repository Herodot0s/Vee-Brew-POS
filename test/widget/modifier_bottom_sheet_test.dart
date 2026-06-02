import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/models/product.dart';
import 'package:veebrew/widgets/modifier_bottom_sheet.dart';
import 'package:veebrew/database/drift_database.dart' hide Product;
import 'package:veebrew/providers/database_provider.dart';

void main() {
  testWidgets(
    'ModifierBottomSheet shows options and updates calculated price',
    (tester) async {
      final db = AppDatabase.memory();
      await db.seedInitialData();

      const product = Product(
        id: 'mt_wintermelon',
        name: 'Wintermelon Milk Tea',
        basePrice: 28.0,
        categoryId: 'milk_tea',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => ModifierBottomSheet.show(context, product),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Wintermelon Milk Tea'), findsOneWidget);
      expect(find.text('100% Sugar'), findsOneWidget);

      // Find the ChoiceChip that contains the text 'Large'
      final largeChip = find.ancestor(
        of: find.text('Large'),
        matching: find.byType(ChoiceChip),
      );
      await tester.tap(largeChip);
      await tester.pumpAndSettle();

      // Verify calculated price update in footer action button
      expect(find.text('₱38.00'), findsOneWidget);

      await db.close();
      await tester.pumpAndSettle();
    },
  );
}
