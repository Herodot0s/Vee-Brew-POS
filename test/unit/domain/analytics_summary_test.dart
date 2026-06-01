import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/domain/analytics_summary.dart';

void main() {
  test('AnalyticsSummary holds expanded metrics', () {
    final summary = AnalyticsSummary(
      totalRevenue: 150.0,
      netSales: 130.0,
      taxCollected: 20.0,
      totalOrders: 5,
      averageOrderValue: 30.0,
      totalQuantity: 10,
      topProducts: {'Espresso': 100.0, 'Latte': 50.0},
      paymentMethods: {'Cash': 50.0, 'Card': 100.0},
      peakHours: {8: 2, 9: 3},
    );

    expect(summary.netSales, 130.0);
    expect(summary.taxCollected, 20.0);
    expect(summary.totalOrders, 5);
    expect(summary.averageOrderValue, 30.0);
    expect(summary.topProducts['Espresso'], 100.0);
    expect(summary.paymentMethods['Card'], 100.0);
    expect(summary.peakHours[9], 3);
  });
}
