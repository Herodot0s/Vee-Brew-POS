import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/domain/analytics_summary.dart';

void main() {
  test('calculateAnalytics aggregates orders correctly', () {
    // Mock data mimicking database results
    final orders = [
      {'totalAmount': 10.0, 'quantity': 2},
      {'totalAmount': 20.0, 'quantity': 1},
    ];

    final summary = calculateAnalytics(orders);

    expect(summary.totalRevenue, 30.0);
    expect(summary.totalQuantity, 3);
  });
}

// Logic to be moved to provider
AnalyticsSummary calculateAnalytics(List<Map<String, dynamic>> orders) {
  double revenue = 0;
  int quantity = 0;
  for (final order in orders) {
    revenue += order['totalAmount'] as double;
    quantity += order['quantity'] as int;
  }
  return AnalyticsSummary(
    totalRevenue: revenue,
    netSales: revenue * 0.9,
    taxCollected: revenue * 0.1,
    totalOrders: orders.length,
    averageOrderValue: orders.isEmpty ? 0 : revenue / orders.length,
    totalQuantity: quantity,
  );
}
