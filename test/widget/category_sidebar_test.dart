import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/widgets/category_sidebar.dart';
import 'package:veebrew/providers/category_provider.dart';

void main() {
  testWidgets('CategorySidebar renders and updates state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 250,
              child: CategorySidebar(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Milk Tea'), findsOneWidget);
    expect(find.text('Cheesecake'), findsOneWidget);

    await tester.tap(find.text('Cheesecake'));
    await tester.pumpAndSettle();

    // Verify selection is updated by reading state through context/container
    final container = ProviderScope.containerOf(tester.element(find.byType(CategorySidebar)));
    expect(container.read(selectedCategoryProvider), 'cheesecake');
  });
}
