import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/providers/mock_analytics_provider.dart';

void main() {
  test('mockAnalyticsProvider returns populated AnalyticsSummary', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final summary = await container.read(mockAnalyticsProvider.future);
    
    expect(summary.totalRevenue, greaterThan(0));
    expect(summary.netSales, greaterThan(0));
    expect(summary.taxCollected, greaterThan(0));
    expect(summary.totalOrders, greaterThan(0));
    expect(summary.averageOrderValue, greaterThan(0));
    expect(summary.topProducts.isNotEmpty, true);
    expect(summary.paymentMethods.isNotEmpty, true);
    expect(summary.peakHours.isNotEmpty, true);
  });
}
