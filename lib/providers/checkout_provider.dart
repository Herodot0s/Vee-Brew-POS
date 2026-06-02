import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import 'database_provider.dart';
import 'cart_provider.dart';
import 'admin_provider.dart';

final checkoutServiceProvider = Provider((ref) => CheckoutService(ref));

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.calculatedPrice);
});

class CheckoutService {
  final Ref _ref;
  CheckoutService(this._ref);

  Future<void> processCheckout(String paymentMethod) async {
    if (!['Cash', 'Card', 'GCash'].contains(paymentMethod)) {
      throw Exception('Unsupported payment method: $paymentMethod');
    }

    final db = _ref.read(databaseProvider);
    final cartItems = _ref.read(cartProvider);
    final total = _ref.read(cartTotalProvider);

    if (cartItems.isEmpty) return;

    final stopwatch = Stopwatch()..start();
    final now = DateTime.now();
    final datePrefix =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    await db.transaction(() async {
      // Daily sequence number
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayOrders = await (db.select(
        db.orders,
      )..where((t) => t.createdAt.isBiggerOrEqualValue(todayStart))).get();
      final seqNum = (todayOrders.length + 1).toString().padLeft(3, '0');
      final orderNumber = '$datePrefix-$seqNum';

      // Insert order
      final orderId = await db
          .into(db.orders)
          .insert(
            OrdersCompanion.insert(
              orderNumber: orderNumber,
              totalAmount: total,
              paymentMethod: paymentMethod,
              createdAt: now,
              isSynced: const Value(false),
            ),
          );

      // Insert line items
      for (final item in cartItems) {
        final modsJson = jsonEncode(
          item.selectedModifiers
              .map(
                (m) => {'id': m.id, 'name': m.name, 'priceDelta': m.priceDelta},
              )
              .toList(),
        );

        await db
            .into(db.orderItems)
            .insert(
              OrderItemsCompanion.insert(
                orderId: orderId,
                productId: item.product.id,
                quantity: 1,
                priceAtTime: item.calculatedPrice,
                selectedModifiers: modsJson,
              ),
            );
      }
    });

    stopwatch.stop();
    _ref
        .read(checkoutDurationProvider.notifier)
        .addDuration(stopwatch.elapsedMilliseconds);

    // Clear cart after successful save
    _ref.read(cartProvider.notifier).clearCart();
  }
}
