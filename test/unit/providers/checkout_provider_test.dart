import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/providers/checkout_provider.dart';
import 'package:veebrew/providers/cart_provider.dart';
import 'package:veebrew/providers/database_provider.dart';
import 'package:veebrew/database/drift_database.dart' hide Product, OrderItem;
import 'package:veebrew/models/product.dart';
import 'package:veebrew/models/order_item.dart';

void main() {
  test('CheckoutService supports GCash method', () async {
    final db = AppDatabase.memory();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );

    // Mock cart items so processCheckout does not abort early
    final cartNotifier = container.read(cartProvider.notifier);
    const mockProduct = Product(
      id: 'prod1',
      name: 'Test Coffee',
      basePrice: 100.0,
      categoryId: 'cat1',
    );
    cartNotifier.addConfiguredItem(
      const OrderItem(product: mockProduct, selectedModifiers: []),
    );

    final service = container.read(checkoutServiceProvider);

    // Should not throw an unsupported method exception
    await expectLater(
      service.processCheckout('GCash'),
      completes,
    );

    await db.close();
  });

  test('CheckoutService throws on unsupported method', () async {
    final db = AppDatabase.memory();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );

    final cartNotifier = container.read(cartProvider.notifier);
    const mockProduct = Product(
      id: 'prod1',
      name: 'Test Coffee',
      basePrice: 100.0,
      categoryId: 'cat1',
    );
    cartNotifier.addConfiguredItem(
      const OrderItem(product: mockProduct, selectedModifiers: []),
    );

    final service = container.read(checkoutServiceProvider);

    await expectLater(
      service.processCheckout('Bitcoin'),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Unsupported payment method: Bitcoin'))),
    );

    await db.close();
  });

  test('CheckoutService saves optional customer name', () async {
    final db = AppDatabase.memory();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );

    final cartNotifier = container.read(cartProvider.notifier);
    cartNotifier.addConfiguredItem(
      const OrderItem(
        product: Product(id: 'prod1', name: 'Coffee', basePrice: 100.0, categoryId: 'cat1'),
        selectedModifiers: [],
      ),
    );

    final service = container.read(checkoutServiceProvider);
    final orderNum = await service.processCheckout('GCash', customerName: 'Alice');

    final order = await (db.select(db.orders)..where((t) => t.orderNumber.equals(orderNum))).getSingle();
    expect(order.customerName, 'Alice');

    await db.close();
  });
}
