import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import 'database_provider.dart';

enum AdminTab { orders, categories, products, modifiers }

final adminViewActiveProvider = StateProvider<bool>((ref) => false);
final adminTabProvider = StateProvider<AdminTab>((ref) => AdminTab.orders);

// Performance latency tracking
class CheckoutDurationNotifier extends StateNotifier<List<int>> {
  CheckoutDurationNotifier() : super(const []);

  void addDuration(int milliseconds) {
    state = [...state, milliseconds];
  }
}

final checkoutDurationProvider = StateNotifierProvider<CheckoutDurationNotifier, List<int>>((ref) {
  return CheckoutDurationNotifier();
});

// Orders stream provider
final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.orders)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch();
});

// Order items stream provider for an order id
final orderItemsProvider = FutureProvider.family<List<OrderItemData>, int>((ref, orderId) {
  final db = ref.read(databaseProvider);
  return (db.select(db.orderItems)..where((t) => t.orderId.equals(orderId))).get();
});
