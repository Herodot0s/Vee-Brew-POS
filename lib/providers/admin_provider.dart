import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import 'database_provider.dart';

enum AdminTab { orders, categories, products, modifiers }

final adminViewActiveProvider = NotifierProvider<AdminViewNotifier, bool>(() => AdminViewNotifier());

class AdminViewNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  set value(bool v) => state = v;
}

final adminTabProvider = NotifierProvider<AdminTabNotifier, AdminTab>(() => AdminTabNotifier());

class AdminTabNotifier extends Notifier<AdminTab> {
  @override
  AdminTab build() => AdminTab.orders;
  set value(AdminTab v) => state = v;
}

final isAdminModeProvider = NotifierProvider<AdminModeNotifier, bool>(() => AdminModeNotifier());

class AdminModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  set value(bool v) => state = v;
}

// Performance latency tracking
final checkoutDurationProvider = NotifierProvider<CheckoutDurationNotifier, List<int>>(() => CheckoutDurationNotifier());

class CheckoutDurationNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => [];

  void addDuration(int milliseconds) {
    state = [...state, milliseconds];
  }
}

// Orders stream provider
final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.orders)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch();
});

// Order items stream provider for an order id
final orderItemsProvider = FutureProvider.family<List<OrderItem>, int>((ref, orderId) {
  final db = ref.read(databaseProvider);
  return (db.select(db.orderItems)..where((t) => t.orderId.equals(orderId))).get();
});
