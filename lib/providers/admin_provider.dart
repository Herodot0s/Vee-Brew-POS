import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import 'database_provider.dart';

enum AdminTab { orders, categories, products, modifiers }

final adminViewActiveProvider = NotifierProvider<AdminViewNotifier, bool>(
  () => AdminViewNotifier(),
);

class AdminViewNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  set value(bool v) => state = v;
}

final adminTabProvider = NotifierProvider<AdminTabNotifier, AdminTab>(
  () => AdminTabNotifier(),
);

class AdminTabNotifier extends Notifier<AdminTab> {
  @override
  AdminTab build() => AdminTab.orders;
  set value(AdminTab v) => state = v;
}

final isAdminModeProvider = NotifierProvider<AdminModeNotifier, bool>(
  () => AdminModeNotifier(),
);

class AdminModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  set value(bool v) => state = v;
}

// Performance latency tracking
final checkoutDurationProvider =
    NotifierProvider<CheckoutDurationNotifier, List<int>>(
      () => CheckoutDurationNotifier(),
    );

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
  return (db.select(db.orders)..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]))
      .watch();
});

// Order items stream provider for an order id
final orderItemsProvider = FutureProvider.family<List<OrderItem>, int>((
  ref,
  orderId,
) {
  final db = ref.read(databaseProvider);
  return (db.select(
    db.orderItems,
  )..where((t) => t.orderId.equals(orderId))).get();
});

// Admin Product Filtering
final adminSearchQueryProvider = NotifierProvider<AdminSearchQuery, String>(
  () => AdminSearchQuery(),
);

class AdminSearchQuery extends Notifier<String> {
  @override
  String build() => '';
  set value(String v) => state = v;
}

final adminSelectedCategoryProvider =
    NotifierProvider<AdminSelectedCategory, String?>(
      () => AdminSelectedCategory(),
    );

class AdminSelectedCategory extends Notifier<String?> {
  @override
  String? build() => null;
  set value(String? v) => state = v;
}

final adminFilteredProductsProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = ref.watch(adminSearchQueryProvider).toLowerCase();
  final catId = ref.watch(adminSelectedCategoryProvider);

  return (db.select(db.products)..where((t) {
        Expression<bool> predicate = const Constant(true);
        if (query.isNotEmpty) {
          predicate = predicate & t.name.lower().like('%$query%');
        }
        if (catId != null) {
          predicate = predicate & t.categoryId.equals(catId);
        }
        return predicate;
      }))
      .watch();
});

// Admin Modifier Filtering
final adminModifierSearchQueryProvider =
    NotifierProvider<AdminModifierSearchQuery, String>(
      () => AdminModifierSearchQuery(),
    );

class AdminModifierSearchQuery extends Notifier<String> {
  @override
  String build() => '';
  set value(String v) => state = v;
}

final adminSelectedModifierGroupProvider =
    NotifierProvider<AdminSelectedModifierGroup, String?>(
      () => AdminSelectedModifierGroup(),
    );

class AdminSelectedModifierGroup extends Notifier<String?> {
  @override
  String? build() => null;
  set value(String? v) => state = v;
}

class ModifierWithProduct {
  final Modifier modifier;
  final Product? product;
  final int productCount;

  const ModifierWithProduct({
    required this.modifier,
    this.product,
    this.productCount = 1,
  });
}

final adminFilteredModifiersProvider =
    StreamProvider<List<ModifierWithProduct>>((ref) {
      final db = ref.watch(databaseProvider);
      final query = ref.watch(adminModifierSearchQueryProvider).toLowerCase();
      final groupId = ref.watch(adminSelectedModifierGroupProvider);

      final queryBuilder = db.select(db.modifiers).join([
        leftOuterJoin(
          db.products,
          db.products.id.equalsExp(db.modifiers.productId),
        ),
      ]);

      Expression<bool> predicate = const Constant(true);
      if (query.isNotEmpty) {
        predicate =
            predicate &
            (db.modifiers.name.lower().like('%$query%') |
                db.products.name.lower().like('%$query%'));
      }
      if (groupId != null) {
        predicate = predicate & db.modifiers.groupName.equals(groupId);
      }

      queryBuilder.where(predicate);
      queryBuilder.orderBy([
        OrderingTerm(expression: db.modifiers.groupName),
        OrderingTerm(expression: db.modifiers.name),
        OrderingTerm(expression: db.modifiers.priceDelta),
      ]);

      return queryBuilder.watch().map((rows) {
        final groupedRows = <String, List<ModifierWithProduct>>{};

        for (final row in rows) {
          final modifier = row.readTable(db.modifiers);
          final key = [
            modifier.id,
            modifier.groupName,
            modifier.name,
            modifier.priceDelta,
          ].join('\u0000');

          groupedRows
              .putIfAbsent(key, () => [])
              .add(
                ModifierWithProduct(
                  modifier: modifier,
                  product: row.readTableOrNull(db.products),
                ),
              );
        }

        return groupedRows.values.map((group) {
          final first = group.first;
          return ModifierWithProduct(
            modifier: first.modifier,
            product: group.length == 1 ? first.product : null,
            productCount: group.length,
          );
        }).toList();
      });
    });
