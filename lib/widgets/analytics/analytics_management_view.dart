import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../analytics/revenue_card.dart';
import '../analytics/top_products_list.dart';
import 'components/time_range_selector.dart';

class AnalyticsManagementView extends ConsumerWidget {
  const AnalyticsManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder analytics data for now, integration with provider will follow
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const TimeRangeSelector(),
          const SizedBox(height: 16),
          const RevenueCard(revenue: 12500.50),
          const SizedBox(height: 16),
          Expanded(
            child: TopProductsList(
              products: [
                ProductStat(name: 'Espresso', quantity: 45),
                ProductStat(name: 'Latte', quantity: 32),
                ProductStat(name: 'Croissant', quantity: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
