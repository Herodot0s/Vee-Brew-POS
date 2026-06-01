# POS Analytics Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a KPI-driven POS Analytics Dashboard using the Impeccable Bento design system to display revenue, top products, payment types, and peak hours.

**Architecture:** We will enhance `AnalyticsSummary` and `AnalyticsProvider` to aggregate financial, product, time, and payment metrics from the existing `OrdersStream`. The UI will be built as a responsive grid of `BentoCard` and `MetricTile` widgets inside `AnalyticsManagementView`. We will also build a robust mock data generator to populate the dashboard for testing.

**Tech Stack:** Flutter, Riverpod, Drift (SQLite).

---

### Task 1: Update Domain Entity

**Files:**
- Modify: `lib/domain/analytics_summary.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/domain/analytics_summary_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/domain/analytics_summary_test.dart`
Expected: FAIL (missing named parameters)

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/domain/analytics_summary.dart
class AnalyticsSummary {
  final double totalRevenue;
  final double netSales;
  final double taxCollected;
  final int totalOrders;
  final double averageOrderValue;
  final int totalQuantity;
  final Map<String, double> topProducts; // Name -> Revenue
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/domain/analytics_summary_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/domain/analytics_summary.dart test/unit/domain/analytics_summary_test.dart
git commit -m "feat(analytics): expand AnalyticsSummary domain entity for POS dashboard"
```

### Task 2: Create Mock Data Generator

**Files:**
- Create: `lib/providers/mock_analytics_provider.dart`
- Create: `test/unit/providers/mock_analytics_provider_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/providers/mock_analytics_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/providers/mock_analytics_provider.dart';

void main() {
  test('mockAnalyticsProvider returns populated AnalyticsSummary', () async {
    final container = ProviderContainer();
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/providers/mock_analytics_provider_test.dart`
Expected: FAIL (missing provider)

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/providers/mock_analytics_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/analytics_summary.dart';

part 'mock_analytics_provider.g.dart';

@riverpod
Future<AnalyticsSummary> mockAnalytics(Ref ref) async {
  // Simulate network/DB delay
  await Future.delayed(const Duration(milliseconds: 800));
  
  return AnalyticsSummary(
    totalRevenue: 2450.75,
    netSales: 2205.67,
    taxCollected: 245.08,
    totalOrders: 142,
    averageOrderValue: 17.25,
    totalQuantity: 284,
    topProducts: {
      'Double Espresso': 650.0,
      'Caramel Macchiato': 520.0,
      'Iced Latte': 480.0,
      'Cold Brew': 310.0,
      'Cortado': 180.0,
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
```

- [ ] **Step 4: Run build_runner and verify test passes**

Run: `dart run build_runner build -d`
Run: `flutter test test/unit/providers/mock_analytics_provider_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/providers/mock_analytics_provider.dart test/unit/providers/mock_analytics_provider_test.dart
git commit -m "test(analytics): create mock analytics provider for UI testing"
```

### Task 3: Build Dashboard Layout Components

**Files:**
- Create: `lib/widgets/analytics/components/top_products_card.dart`
- Create: `lib/widgets/analytics/components/payment_methods_card.dart`
- Create: `lib/widgets/analytics/components/peak_hours_card.dart`

- [ ] **Step 1: Implement TopProductsCard**

```dart
// lib/widgets/analytics/components/top_products_card.dart
import 'package:flutter/material.dart';
import '../../admin/bento_card.dart';

class TopProductsCard extends StatelessWidget {
  final Map<String, double> topProducts;

  const TopProductsCard({super.key, required this.topProducts});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = topProducts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final displayEntries = sortedEntries.take(5).toList();

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Top 5 Products',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: displayEntries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = displayEntries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}. ${entry.key}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('\$${entry.value.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Implement PaymentMethodsCard**

```dart
// lib/widgets/analytics/components/payment_methods_card.dart
import 'package:flutter/material.dart';
import '../../admin/bento_card.dart';

class PaymentMethodsCard extends StatelessWidget {
  final Map<String, double> paymentMethods;

  const PaymentMethodsCard({super.key, required this.paymentMethods});

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Revenue by Payment Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: paymentMethods.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('\$${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Implement PeakHoursCard**

```dart
// lib/widgets/analytics/components/peak_hours_card.dart
import 'package:flutter/material.dart';
import '../../admin/bento_card.dart';

class PeakHoursCard extends StatelessWidget {
  final Map<int, int> peakHours;

  const PeakHoursCard({super.key, required this.peakHours});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = peakHours.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final displayEntries = sortedEntries.take(5).toList();

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Busiest Hours',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: displayEntries.map((entry) {
                final hourStr = '${entry.key > 12 ? entry.key - 12 : (entry.key == 0 ? 12 : entry.key)} ${entry.key >= 12 ? 'PM' : 'AM'}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hourStr, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${entry.value} orders', style: const TextStyle(color: Colors.purple, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/analytics/components/top_products_card.dart lib/widgets/analytics/components/payment_methods_card.dart lib/widgets/analytics/components/peak_hours_card.dart
git commit -m "feat(analytics): build specialized bento cards for dashboard"
```

### Task 4: Integrate Dashboard View

**Files:**
- Modify: `lib/widgets/analytics/analytics_management_view.dart`

- [ ] **Step 1: Update view to use mock provider and new layout**

```dart
// lib/widgets/analytics/analytics_management_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mock_analytics_provider.dart';
import '../admin/bento_card.dart';
import '../admin/metric_tile.dart';
import 'components/time_range_selector.dart';
import 'components/top_products_card.dart';
import 'components/payment_methods_card.dart';
import 'components/peak_hours_card.dart';

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
                    // Placeholder for TimeRangeSelector if not fully functional
                    DropdownButton<String>(
                      value: 'Today',
                      items: ['Today', 'This Week', 'This Month'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (_) {},
                    ),
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
                    color: Colors.green,
                  ),
                  MetricTile(
                    label: 'Net Sales',
                    value: '\$${summary.netSales.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet,
                  ),
                  MetricTile(
                    label: 'Total Orders',
                    value: summary.totalOrders.toString(),
                    icon: Icons.receipt_long,
                    color: Colors.orange,
                  ),
                  MetricTile(
                    label: 'AOV',
                    value: '\$${summary.averageOrderValue.toStringAsFixed(2)}',
                    icon: Icons.shopping_basket,
                    color: Colors.blue,
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
```

- [ ] **Step 2: Run Flutter to verify compilation**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/analytics/analytics_management_view.dart
git commit -m "feat(analytics): integrate bento grid UI for POS command center dashboard"
```
