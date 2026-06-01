import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/database/drift_database.dart';
import 'package:veebrew/providers/admin_provider.dart';
import 'package:veebrew/providers/category_provider.dart';
import 'package:veebrew/providers/database_provider.dart';
import 'package:veebrew/screens/pos_screen.dart';

void main() {
  testWidgets('sidebar toggles admin frame and category tap returns to POS', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    await db.seedInitialData();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: POSScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Admin Area'), findsOneWidget);
    expect(find.text('Admin Console'), findsNothing);

    await tester.tap(find.text('Admin Area'));
    await tester.pumpAndSettle();

    expect(find.text('POS Terminal'), findsOneWidget);
    expect(find.text('Admin Console'), findsOneWidget);
    expect(find.text('Order History'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Modifiers'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(POSScreen)),
    );
    expect(container.read(adminViewActiveProvider), isTrue);

    await tester.tap(find.text('Cheesecake'));
    await tester.pumpAndSettle();

    expect(container.read(selectedCategoryProvider), 'cheesecake');
    expect(container.read(adminViewActiveProvider), isFalse);
    expect(find.text('Admin Console'), findsNothing);

    await db.close();
  });
}
