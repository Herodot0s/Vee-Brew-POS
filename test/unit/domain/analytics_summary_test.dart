import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/domain/analytics_summary.dart';

void main() {
  test('AnalyticsSummary holds expanded metrics and handles default values', () {
    const summary = AnalyticsSummary(
      totalRevenue: 150.0,
      netSales: 130.0,
      taxCollected: 20.0,
      totalOrders: 5,
      averageOrderValue: 30.0,
      totalQuantity: 10,
    );

    expect(summary.totalRevenue, 150.0);
    expect(summary.netSales, 130.0);
    expect(summary.taxCollected, 20.0);
    expect(summary.totalOrders, 5);
    expect(summary.averageOrderValue, 30.0);
    expect(summary.totalQuantity, 10);
    expect(summary.topProducts, isEmpty);
    expect(summary.paymentMethods, isEmpty);
    expect(summary.peakHours, isEmpty);
  });

  test('AnalyticsSummary supports value equality', () {
    const summary1 = AnalyticsSummary(
      totalRevenue: 150.0,
      netSales: 130.0,
      taxCollected: 20.0,
      totalOrders: 5,
      averageOrderValue: 30.0,
      totalQuantity: 10,
      topProducts: {'Espresso': (quantity: 50, revenue: 100.0), 'Latte': (quantity: 20, revenue: 50.0)},
      paymentMethods: {'Cash': 50.0, 'Card': 100.0},
      peakHours: {8: 2, 9: 3},
    );

    const summary2 = AnalyticsSummary(
      totalRevenue: 150.0,
      netSales: 130.0,
      taxCollected: 20.0,
      totalOrders: 5,
      averageOrderValue: 30.0,
      totalQuantity: 10,
      topProducts: {'Espresso': (quantity: 50, revenue: 100.0), 'Latte': (quantity: 20, revenue: 50.0)},
      paymentMethods: {'Cash': 50.0, 'Card': 100.0},
      peakHours: {8: 2, 9: 3},
    );

    const summary3 = AnalyticsSummary(
      totalRevenue: 200.0,
      netSales: 180.0,
      taxCollected: 20.0,
      totalOrders: 6,
      averageOrderValue: 30.0,
      totalQuantity: 12,
    );

    expect(summary1, equals(summary2));
    expect(summary1.hashCode, equals(summary2.hashCode));
    expect(summary1, isNot(equals(summary3)));
  });
}
