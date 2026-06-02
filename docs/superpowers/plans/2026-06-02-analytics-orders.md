# Analytics Date Range & Order Detail Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modify POS dashboard analytics view to allow custom date/date range selection, and enhance the order history screen to show order items, selected modifiers, and order timestamp in 12-hour format inside the expanded tile (dropdown).

**Architecture:** Extend analytics state with custom class that stores preset or custom start/end dates. Query database with start and end dates. Use a new FutureProvider for order items and join with products to render order details inside the order history ExpansionTile.

**Tech Stack:** Flutter, Drift, Riverpod

---

### Task 1: Update Analytics Filter State Provider
**Files:**
* Modify: `lib/providers/analytics_state_provider.dart`
* Test: Create a new test inside `test/providers/analytics_state_provider_test.dart`

- [ ] **Step 1: Implement AnalyticsFilterState and update Notifier**
Update `lib/providers/analytics_state_provider.dart` to define the state model and calculate preset date ranges.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimeRange { day, week, month, year, custom }

class AnalyticsFilterState {
  final TimeRange range;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsFilterState({
    required this.range,
    required this.startDate,
    required this.endDate,
  });

  AnalyticsFilterState copyWith({
    TimeRange? range,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AnalyticsFilterState(
      range: range ?? this.range,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class AnalyticsStateNotifier extends Notifier<AnalyticsFilterState> {
  @override
  AnalyticsFilterState build() {
    return _buildForRange(TimeRange.day);
  }

  void setTimeRange(TimeRange range) {
    if (range != TimeRange.custom) {
      state = _buildForRange(range);
    }
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = AnalyticsFilterState(
      range: TimeRange.custom,
      startDate: DateTime(start.year, start.month, start.day, 0, 0, 0),
      endDate: DateTime(end.year, end.month, end.day, 23, 59, 59, 999),
    );
  }

  AnalyticsFilterState _buildForRange(TimeRange range) {
    final now = DateTime.now();
    final DateTime start;
    final DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (range) {
      case TimeRange.day:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        break;
      case TimeRange.week:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 6));
        break;
      case TimeRange.month:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 29));
        break;
      case TimeRange.year:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 364));
        break;
      case TimeRange.custom:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        break;
    }

    return AnalyticsFilterState(
      range: range,
      startDate: start,
      endDate: end,
    );
  }
}

final analyticsStateProvider = NotifierProvider<AnalyticsStateNotifier, AnalyticsFilterState>(
  () => AnalyticsStateNotifier(),
);
```

- [ ] **Step 2: Write test for filter state notifier**
Create `test/providers/analytics_state_provider_test.dart` to verify ranges and updates.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/providers/analytics_state_provider.dart';

void main() {
  test('AnalyticsStateNotifier initializes and updates state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var state = container.read(analyticsStateProvider);
    expect(state.range, TimeRange.day);

    container.read(analyticsStateProvider.notifier).setTimeRange(TimeRange.week);
    state = container.read(analyticsStateProvider);
    expect(state.range, TimeRange.week);

    final start = DateTime(2026, 6, 1);
    final end = DateTime(2026, 6, 2);
    container.read(analyticsStateProvider.notifier).setCustomRange(start, end);
    state = container.read(analyticsStateProvider);
    expect(state.range, TimeRange.custom);
    expect(state.startDate.year, 2026);
    expect(state.endDate.year, 2026);
  });
}
```

- [ ] **Step 3: Run the test to verify it passes**
Run: `flutter test test/providers/analytics_state_provider_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**
```bash
git add lib/providers/analytics_state_provider.dart test/providers/analytics_state_provider_test.dart
git commit -m "feat: update analytics state notifier for custom range support"
```

---

### Task 2: Update Analytics Summary Provider
**Files:**
* Modify: `lib/providers/analytics_provider.dart`

- [ ] **Step 1: Update DB query filter**
Update the order `createdAt` query conditions in `lib/providers/analytics_provider.dart` to filter between `startDate` and `endDate`.

Replace:
```dart
  final timeRange = ref.watch(analyticsStateProvider);

  final now = DateTime.now();
  final DateTime startDate;
  switch (timeRange) {
    case TimeRange.day:
      startDate = DateTime(now.year, now.month, now.day);
      break;
    case TimeRange.week:
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      break;
    case TimeRange.month:
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
      break;
    case TimeRange.year:
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 364));
      break;
  }

  final query = db.select(db.orders).join([
    innerJoin(db.orderItems, db.orderItems.orderId.equalsExp(db.orders.id)),
    innerJoin(db.products, db.products.id.equalsExp(db.orderItems.productId)),
  ]);

  query.where(db.orders.createdAt.isBiggerOrEqualValue(startDate));
```

With:
```dart
  final filter = ref.watch(analyticsStateProvider);

  final query = db.select(db.orders).join([
    innerJoin(db.orderItems, db.orderItems.orderId.equalsExp(db.orders.id)),
    innerJoin(db.products, db.products.id.equalsExp(db.orderItems.productId)),
  ]);

  query.where(
    db.orders.createdAt.isBiggerOrEqualValue(filter.startDate) &
    db.orders.createdAt.isSmallerOrEqualValue(filter.endDate)
  );
```

- [ ] **Step 2: Run all tests to ensure no compilation issues**
Run: `flutter test`
Expected: PASS

- [ ] **Step 3: Commit**
```bash
git add lib/providers/analytics_provider.dart
git commit -m "feat: adjust analytics query filter for range constraints"
```

---

### Task 3: Build Custom Date Picker and UI Display
**Files:**
* Modify: `lib/widgets/analytics/components/time_range_selector.dart`
* Modify: `lib/widgets/analytics/analytics_management_view.dart`

- [ ] **Step 1: Update UI selector for custom date option**
Modify `lib/widgets/analytics/components/time_range_selector.dart` to add the "Custom" choice chip and open a date picker dialog.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/binance_theme.dart';
import '../../../providers/analytics_state_provider.dart';

class TimeRangeSelector extends ConsumerWidget {
  const TimeRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(analyticsStateProvider);
    return Row(
      children: TimeRange.values.map((range) {
        final isSelected = range == currentFilter.range;
        return Padding(
          padding: const EdgeInsets.only(right: BinanceTheme.spaceXs),
          child: ChoiceChip(
            label: Text(range.name.capitalize()),
            selected: isSelected,
            onSelected: (_) async {
              if (range == TimeRange.custom) {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: DateTimeRange(
                    start: currentFilter.startDate,
                    end: currentFilter.endDate,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: BinanceTheme.primary,
                          onPrimary: BinanceTheme.onPrimary,
                          surface: BinanceTheme.surfaceCardDark,
                          onSurface: BinanceTheme.onDark,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  ref.read(analyticsStateProvider.notifier).setCustomRange(picked.start, picked.end);
                }
              } else {
                ref.read(analyticsStateProvider.notifier).setTimeRange(range);
              }
            },
          ),
        );
      }).toList(),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
```

- [ ] **Step 2: Add date display text below app bar**
Modify `lib/widgets/analytics/analytics_management_view.dart` to show a beautiful date string corresponding to the filtered range.

```dart
// Modify the title/header row in lib/widgets/analytics/analytics_management_view.dart to show selected date/range
// Below constraints:
```
Add helper functions to format dates nicely:
```dart
String _formatDateShort(DateTime dt) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}
```

Update rows 26-34 in `lib/widgets/analytics/analytics_management_view.dart`:
```dart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentFilter.range == TimeRange.custom
                              ? 'Range: ${_formatDateShort(currentFilter.startDate)} - ${_formatDateShort(currentFilter.endDate)}'
                              : 'Preset: ${_formatDateShort(currentFilter.startDate)} - ${_formatDateShort(currentFilter.endDate)}',
                          style: const TextStyle(
                            color: BinanceTheme.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Time Range: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const TimeRangeSelector(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
```

- [ ] **Step 3: Commit**
```bash
git add lib/widgets/analytics/components/time_range_selector.dart lib/widgets/analytics/analytics_management_view.dart
git commit -m "feat: render date range text and handle calendar date picker dialogs"
```

---

### Task 4: Enhance Order Providers for Joining and Modifiers
**Files:**
* Modify: `lib/providers/admin_provider.dart`

- [ ] **Step 1: Add new joined Order Items provider**
Add the `OrderItemWithProduct` model and `orderItemsWithProductProvider` provider to `lib/providers/admin_provider.dart`.

```dart
class OrderItemWithProduct {
  final OrderItem orderItem;
  final Product product;
  OrderItemWithProduct({required this.orderItem, required this.product});
}

final orderItemsWithProductProvider = FutureProvider.family<List<OrderItemWithProduct>, int>((ref, orderId) async {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.orderItems).join([
    innerJoin(db.products, db.products.id.equalsExp(db.orderItems.productId)),
  ])..where(db.orderItems.orderId.equals(orderId));
  
  final rows = await query.get();
  return rows.map((row) {
    return OrderItemWithProduct(
      orderItem: row.readTable(db.orderItems),
      product: row.readTable(db.products),
    );
  }).toList();
});
```

- [ ] **Step 2: Verify the compilation works**
Run: `flutter test test/admin_test.dart`
Expected: PASS

- [ ] **Step 3: Commit**
```bash
git add lib/providers/admin_provider.dart
git commit -m "feat: add orderItemsWithProductProvider with product joined queries"
```

---

### Task 5: Enhance Order Dropdown (ExpansionTile) UI
**Files:**
* Modify: `lib/screens/admin_dashboard_screen.dart`

- [ ] **Step 1: Implement premium detail dropdown layout in _OrderHistoryView**
Modify `lib/screens/admin_dashboard_screen.dart` to fetch and render order items, selected modifiers, quantities, and a nicely structured order metadata summary (placed date-time in 12-hour AM/PM format, payment method, sync status).

Replace `_OrderHistoryView` build method:
```dart
class _OrderHistoryView extends ConsumerWidget {
  const _OrderHistoryView({super.key});

  String _formatDateTime12H(DateTime dt) {
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    
    int hour = dt.hour;
    final String period;
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour -= 12;
    } else {
      period = 'AM';
      if (hour == 0) hour = 12;
    }
    final hourStr = hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    
    return '$year-$month-$day $hourStr:$minute:$second $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    return ordersAsync.when(
      data: (orders) => ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: BinanceTheme.surfaceCardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BinanceTheme.surfaceElevatedDark,
                width: 1,
              ),
            ),
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              backgroundColor: Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
              title: Text(
                'Order #${order.orderNumber}',
                style: const TextStyle(
                  color: BinanceTheme.onDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Placed: ${_formatDateTime12H(order.createdAt)}',
                  style: const TextStyle(
                    color: BinanceTheme.muted,
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.isSynced
                          ? Colors.green.withOpacity(0.1)
                          : BinanceTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.isSynced ? 'Synced' : 'Pending',
                      style: TextStyle(
                        color: order.isSynced ? Colors.green : BinanceTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!order.isSynced)
                    IconButton(
                      icon: const Icon(Icons.sync, color: BinanceTheme.primary),
                      onPressed: () async {
                        final db = ref.read(databaseProvider);
                        await Future.delayed(const Duration(milliseconds: 1200));
                        await (db.update(db.orders)
                              ..where((t) => t.id.equals(order.id)))
                            .write(OrdersCompanion(isSynced: Value(true)));
                      },
                    ),
                ],
              ),
              children: [
                const Divider(color: BinanceTheme.surfaceElevatedDark, height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final itemsAsync = ref.watch(orderItemsWithProductProvider(order.id));
                    return itemsAsync.when(
                      data: (items) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Items in Order:',
                                style: TextStyle(
                                  color: BinanceTheme.muted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...items.map((item) {
                                // Parse modifiers JSON if available
                                List<dynamic> modsList = [];
                                try {
                                  if (item.orderItem.selectedModifiers.isNotEmpty) {
                                    modsList = jsonDecode(item.orderItem.selectedModifiers);
                                  }
                                } catch (_) {}

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${item.product.name} x${item.orderItem.quantity}',
                                            style: const TextStyle(
                                              color: BinanceTheme.onDark,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '₱${item.orderItem.priceAtTime.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: BinanceTheme.onDark,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (modsList.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: modsList.map((m) {
                                              final name = m['name'] ?? '';
                                              final priceDelta = m['priceDelta'] ?? 0.0;
                                              final priceText = priceDelta > 0 ? ' (+₱${priceDelta.toStringAsFixed(0)})' : '';
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: BinanceTheme.surfaceElevatedDark,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '$name$priceText',
                                                  style: const TextStyle(
                                                    color: BinanceTheme.muted,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const Divider(color: BinanceTheme.surfaceElevatedDark, height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Payment Method:',
                                    style: TextStyle(color: BinanceTheme.muted, fontSize: 13),
                                  ),
                                  Text(
                                    order.paymentMethod,
                                    style: const TextStyle(
                                      color: BinanceTheme.onDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(
                                      color: BinanceTheme.onDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '₱${order.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: BinanceTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading items: $err',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      error: (_, __) => const Center(
        child: Text(
          'Error loading orders',
          style: TextStyle(color: Colors.red),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
```

Wait, we also need to import `dart:convert` inside `lib/screens/admin_dashboard_screen.dart` to parse JSON of selectedModifiers!
Ensure `import 'dart:convert';` is present at the top of `lib/screens/admin_dashboard_screen.dart`.

- [ ] **Step 2: Compile and test to ensure all tests pass**
Run: `flutter test`
Expected: PASS

- [ ] **Step 3: Commit**
```bash
git add lib/screens/admin_dashboard_screen.dart
git commit -m "feat: build order tile detailed UI with item modifiers and 12-hour timestamps"
```
