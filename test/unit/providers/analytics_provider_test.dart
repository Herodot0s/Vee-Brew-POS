import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/database/drift_database.dart';
import 'package:veebrew/providers/database_provider.dart';
import 'package:veebrew/providers/analytics_provider.dart';
import 'package:veebrew/providers/analytics_state_provider.dart';
import 'package:drift/drift.dart';

void main() {
  test('analyticsSummaryProvider aggregates database orders correctly', () async {
    final db = AppDatabase.memory();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    // Seed some products
    await db.into(db.categories).insert(
      const CategoriesCompanion(
        id: Value('cat_1'),
        name: Value('Coffee'),
        sortOrder: Value(0),
      ),
    );

    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('prod_1'),
        name: Value('Latte'),
        basePrice: Value(5.0),
        categoryId: Value('cat_1'),
      ),
    );

    // Create an order
    final now = DateTime.now();
    final orderId = await db.into(db.orders).insert(
      OrdersCompanion.insert(
        orderNumber: 'ORD-001',
        totalAmount: 15.0,
        paymentMethod: 'Cash',
        createdAt: now,
        isSynced: const Value(false),
      ),
    );

    await db.into(db.orderItems).insert(
      OrderItemsCompanion.insert(
        orderId: orderId,
        productId: 'prod_1',
        quantity: 3,
        priceAtTime: 5.0,
        selectedModifiers: '[]',
      ),
    );

    // Keep provider alive using listen
    final subscription = container.listen(analyticsSummaryProvider, (previous, next) {});
    final summary = await container.read(analyticsSummaryProvider.future);
    subscription.close();

    expect(summary.totalRevenue, 15.0);
    expect(summary.netSales, 13.5);
    expect(summary.taxCollected, 1.5);
    expect(summary.totalOrders, 1);
    expect(summary.averageOrderValue, 15.0);
    expect(summary.totalQuantity, 3);
    expect(summary.topProducts['Latte']!.quantity, 3);
    expect(summary.topProducts['Latte']!.revenue, 15.0);
    expect(summary.paymentMethods['Cash'], 15.0);
    expect(summary.peakHours[now.hour], 1);
  });
}
