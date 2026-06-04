import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/database/drift_database.dart' show AppDatabase;
import 'package:veebrew/providers/database_provider.dart';
import 'package:veebrew/providers/cart_provider.dart';
import 'package:veebrew/models/product.dart';
import 'package:veebrew/widgets/order_ticket.dart';
import 'package:veebrew/widgets/checkout_modal.dart';

void main() {
  testWidgets('CheckoutModal shows GCash button and transitions to GCash view', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: CheckoutModal()),
        ),
      ),
    );

    expect(find.text('GCASH'), findsOneWidget);

    // Tap GCash
    await tester.tap(find.text('GCASH'));
    await tester.pumpAndSettle();

    // Should show GCash payment view
    expect(find.text('Reference Number'), findsOneWidget);
    expect(find.text('GCASH'), findsNothing); // Original buttons hidden
  });

  testWidgets('CheckoutModal processes payment and clears cart', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    await db.seedInitialData();

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );

    // Seed product to cart
    const product = Product(
      id: 'mt_wintermelon',
      name: 'Wintermelon Milk Tea',
      basePrice: 28.0,
      categoryId: 'milk_tea',
    );
    container.read(cartProvider.notifier).addQuickTap(product);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: OrderTicket())),
      ),
    );

    await tester.pumpAndSettle();

    // Verify "Pay Now" button is active and displays correct total
    expect(find.text('Pay Now'), findsOneWidget);
    expect(find.text('₱28.00'), findsAtLeast(1));

    // Tap "Pay Now"
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();

    // Verify checkout modal is open
    expect(find.text('Checkout'), findsOneWidget);

    // Tap CASH payment button to go to cash payment step
    await tester.tap(find.text('CASH'));
    await tester.pumpAndSettle();

    // Verify cash payment view is shown
    expect(find.text('Cash Payment'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);

    // Tap "Exact" denomination button
    await tester.tap(find.text('Exact'));
    await tester.pumpAndSettle();

    // Tap "Confirm" button
    await tester.tap(find.text('Confirm'));
    await tester.pump(); // Start processing

    // Wait for the simulated checkout processing delay in CheckoutModal
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(); // Dialog shows up

    // Verify success dialog is showing
    expect(find.text('Checkout Complete'), findsOneWidget);

    // Tap Done to dismiss dialog and modal
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Verify checkout modal is dismissed
    expect(find.text('Checkout'), findsNothing);

    // Verify cart is cleared
    expect(container.read(cartProvider), isEmpty);

    // Check if order is saved in the database
    final orders = await db.select(db.orders).get();
    expect(orders.length, 1);
    expect(orders.first.paymentMethod, 'Cash');
    expect(orders.first.totalAmount, 28.0);
    expect(orders.first.amountReceived, 28.0);
    expect(orders.first.changeAmount, 0.0);

    final items = await db.select(db.orderItems).get();
    expect(items.length, 1);
    expect(items.first.productId, 'mt_wintermelon');
    expect(items.first.priceAtTime, 28.0);

    await db.close();
  });
}
