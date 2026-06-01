import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import '../providers/database_provider.dart';
import '../domain/analytics_summary.dart';

part 'analytics_provider.g.dart';

@riverpod
Stream<AnalyticsSummary> analyticsSummary(Ref ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.orders).join([
    innerJoin(db.orderItems, db.orderItems.orderId.equalsExp(db.orders.id)),
  ]))
      .watch()
      .map((rows) {
    double totalRevenue = 0;
    int totalQuantity = 0;
    for (final row in rows) {
      final order = row.readTable(db.orders);
      final item = row.readTable(db.orderItems);
      totalRevenue += order.totalAmount;
      totalQuantity += item.quantity;
    }
    return AnalyticsSummary(
      totalRevenue: totalRevenue,
      totalQuantity: totalQuantity,
    );
  });
}
