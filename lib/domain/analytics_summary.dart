class AnalyticsSummary {
  final double totalRevenue;
  final double netSales;
  final double taxCollected;
  final int totalOrders;
  final double averageOrderValue;
  final int totalQuantity;
  final Map<String, ({int quantity, double revenue})> topProducts; // Name -> (Quantity, Revenue)
  final Map<String, double> paymentMethods; // Type -> Revenue
  final Map<int, int> peakHours; // Hour (0-23) -> Order Count

  AnalyticsSummary({
    required this.totalRevenue,
    required this.netSales,
    required this.taxCollected,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.totalQuantity,
    this.topProducts = const {},
    this.paymentMethods = const {},
    this.peakHours = const {},
  });
}
