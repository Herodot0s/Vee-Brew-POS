import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mock_analytics_provider.dart';
import '../admin/metric_tile.dart';
import 'components/top_products_card.dart';
import 'components/payment_methods_card.dart';
import 'components/peak_hours_card.dart';
import 'components/time_range_selector.dart';
import '../../theme/binance_theme.dart';

class AnalyticsManagementView extends ConsumerWidget {
  const AnalyticsManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Switch to real provider when backend logic is fully written.
    final summaryAsync = ref.watch(mockAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Command Center')),
      body: summaryAsync.when(
        data: (summary) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Time Range: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const TimeRangeSelector(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildListDelegate([
                  MetricTile(
                    label: 'Total Revenue',
                    value: '\$${summary.totalRevenue.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: BinanceTheme.tradingUp,
                  ),
                  MetricTile(
                    label: 'Net Sales',
                    value: '\$${summary.netSales.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet,
                  ),
                  MetricTile(
                    label: 'Tax',
                    value: '\$${summary.taxCollected.toStringAsFixed(2)}',
                    icon: Icons.receipt,
                    color: BinanceTheme.primary,
                  ),
                  MetricTile(
                    label: 'AOV',
                    value: '\$${summary.averageOrderValue.toStringAsFixed(2)}',
                    icon: Icons.shopping_basket,
                    color: BinanceTheme.primary,
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 600,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildListDelegate([
                  TopProductsCard(topProducts: summary.topProducts),
                  PeakHoursCard(peakHours: summary.peakHours),
                  PaymentMethodsCard(paymentMethods: summary.paymentMethods),
                ]),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
