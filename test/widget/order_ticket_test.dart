import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/widgets/order_ticket.dart';
import 'package:veebrew/providers/cart_provider.dart';
import 'package:veebrew/providers/database_provider.dart';
import 'package:veebrew/database/drift_database.dart' hide Product, Category;
import 'package:veebrew/models/product.dart';

void main() {
  testWidgets('OrderTicket shows product name with category prefix', (WidgetTester tester) async {
    final db = AppDatabase.memory();
    await db.seedInitialData();

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );

    const testProduct = Product(
      id: 'mt_wintermelon',
      name: 'Wintermelon Milk Tea',
      basePrice: 28.0,
      categoryId: 'milk_tea',
    );

    container.read(cartProvider.notifier).addQuickTap(testProduct);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: OrderTicket()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('[Milk Tea] Wintermelon Milk Tea'), findsOneWidget);

    await db.close();
  });
}
