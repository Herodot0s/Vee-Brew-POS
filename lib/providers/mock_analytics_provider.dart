import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/analytics_summary.dart';

part 'mock_analytics_provider.g.dart';

@riverpod
Future<AnalyticsSummary> mockAnalytics(Ref ref) async {
  // Simulate network/DB delay
  await Future.delayed(const Duration(milliseconds: 800));
  
  return const AnalyticsSummary(
    totalRevenue: 2450.75,
    netSales: 2205.67,
    taxCollected: 245.08,
    totalOrders: 142,
    averageOrderValue: 17.25,
    totalQuantity: 284,
    topProducts: {
      'Double Espresso': (quantity: 130, revenue: 650.0),
      'Caramel Macchiato': (quantity: 104, revenue: 520.0),
      'Iced Latte': (quantity: 96, revenue: 480.0),
      'Cold Brew': (quantity: 62, revenue: 310.0),
      'Cortado': (quantity: 36, revenue: 180.0),
    },
    paymentMethods: {
      'Credit Card': 1850.50,
      'Cash': 400.25,
      'Mobile Wallet': 200.00,
    },
    peakHours: {
      7: 15,
      8: 45,
      9: 38,
      10: 22,
      11: 12,
      12: 25,
      13: 30,
      14: 18,
    },
  );
}
