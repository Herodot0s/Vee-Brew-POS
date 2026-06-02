import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import '../providers/database_provider.dart';
import '../domain/analytics_summary.dart';
import 'analytics_state_provider.dart';

part 'analytics_provider.g.dart';

@riverpod
Stream<AnalyticsSummary> analyticsSummary(Ref ref) {
  final db = ref.watch(databaseProvider);
  final filter = ref.watch(analyticsStateProvider);

  final query = db.select(db.orders).join([
    innerJoin(db.orderItems, db.orderItems.orderId.equalsExp(db.orders.id)),
    innerJoin(db.products, db.products.id.equalsExp(db.orderItems.productId)),
  ]);

  query.where(
    db.orders.createdAt.isBiggerOrEqualValue(filter.startDate) &
    db.orders.createdAt.isSmallerOrEqualValue(filter.endDate),
  );

  return query.watch().map((rows) {
    double totalRevenue = 0;
    final Map<int, double> orderTotals = {};
    final Map<int, String> orderPaymentMethods = {};
    final Map<int, DateTime> orderTimes = {};

    final Map<String, int> productQuantities = {};
    final Map<String, double> productRevenues = {};

    int totalQuantity = 0;

    for (final row in rows) {
      final order = row.readTable(db.orders);
      final item = row.readTable(db.orderItems);
      final product = row.readTable(db.products);

      orderTotals[order.id] = order.totalAmount;
      orderPaymentMethods[order.id] = order.paymentMethod;
      orderTimes[order.id] = order.createdAt;

      productQuantities[product.name] = (productQuantities[product.name] ?? 0) + item.quantity;
      productRevenues[product.name] = (productRevenues[product.name] ?? 0) + (item.priceAtTime * item.quantity);

      totalQuantity += item.quantity;
    }

    for (final total in orderTotals.values) {
      totalRevenue += total;
    }

    final int totalOrders = orderTotals.length;
    final double netSales = totalRevenue * 0.9;
    final double taxCollected = totalRevenue * 0.1;
    final double averageOrderValue = totalOrders == 0 ? 0.0 : totalRevenue / totalOrders;

    final Map<String, double> paymentMethods = {};
    for (final entry in orderPaymentMethods.entries) {
      final orderId = entry.key;
      final method = entry.value;
      final total = orderTotals[orderId] ?? 0.0;
      paymentMethods[method] = (paymentMethods[method] ?? 0.0) + total;
    }

    final Map<int, int> peakHours = {};
    for (final createdAt in orderTimes.values) {
      final hour = createdAt.hour;
      peakHours[hour] = (peakHours[hour] ?? 0) + 1;
    }

    final Map<String, ({int quantity, double revenue})> topProducts = {};
    productQuantities.forEach((name, qty) {
      final rev = productRevenues[name] ?? 0.0;
      topProducts[name] = (quantity: qty, revenue: rev);
    });

    return AnalyticsSummary(
      totalRevenue: totalRevenue,
      netSales: netSales,
      taxCollected: taxCollected,
      totalOrders: totalOrders,
      averageOrderValue: averageOrderValue,
      totalQuantity: totalQuantity,
      topProducts: topProducts,
      paymentMethods: paymentMethods,
      peakHours: peakHours,
    );
  });
}

