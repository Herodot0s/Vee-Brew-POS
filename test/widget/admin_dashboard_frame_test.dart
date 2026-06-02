import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/database/drift_database.dart';
import 'package:veebrew/providers/admin_provider.dart';
import 'package:veebrew/providers/category_provider.dart';
import 'package:veebrew/providers/database_provider.dart';
import 'package:veebrew/screens/pos_screen.dart';

void main() {
  testWidgets('sidebar toggles admin frame and category tap returns to POS', skip: true, (
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

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Admin Area'), findsOneWidget);
    expect(find.text('Analytics'), findsNothing);

    await tester.tap(find.text('Admin Area'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('POS Terminal'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Modifiers'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(POSScreen)),
    );
    expect(container.read(isAdminModeProvider), isTrue);

    await tester.tap(find.text('Cheesecake'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(container.read(selectedCategoryProvider), 'cheesecake');
    expect(container.read(isAdminModeProvider), isFalse);
    expect(find.text('Orders'), findsNothing);

    await db.close();
  });
}
