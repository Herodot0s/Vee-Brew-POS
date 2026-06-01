import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/widgets/category_sidebar.dart';
import 'package:veebrew/providers/category_provider.dart';
import 'package:veebrew/providers/database_provider.dart';
import 'package:veebrew/database/drift_database.dart';

void main() {
  testWidgets('CategorySidebar renders and updates state', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    await db.seedInitialData();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: Scaffold(body: SizedBox(width: 250, child: CategorySidebar())),
        ),
      ),
    );

    // Wait for the stream to emit
    await tester.pumpAndSettle();

    expect(find.text('Milk Tea'), findsOneWidget);
    expect(find.text('Cheesecake'), findsOneWidget);

    await tester.tap(find.text('Cheesecake'));
    await tester.pumpAndSettle();

    // Verify selection is updated by reading state through context/container
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CategorySidebar)),
    );
    expect(container.read(selectedCategoryProvider), 'cheesecake');

    await db.close();
  });
}
