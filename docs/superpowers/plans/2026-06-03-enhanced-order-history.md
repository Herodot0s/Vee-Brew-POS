# Enhanced Order History Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement detailed order views and time-based filtering in the admin dashboard.

**Architecture:** Use Riverpod to manage filter state and drive a filtered Drift stream. UI uses a Row-based layout for a sidebar and detailed ExpansionTiles.

**Tech Stack:** Flutter, Riverpod, Drift (SQLite).

---

### Task 1: Update Database Logic for Filtering

**Files:**
- Modify: `lib/database/drift_database.dart`

- [ ] **Step 1: Add date range filter to orders selection**

```dart
// lib/database/drift_database.dart

// Inside AppDatabase class
Stream<List<Order>> watchFilteredOrders(DateTime start, DateTime end) {
  return (select(orders)
    ..where((t) => t.createdAt.isBetweenValues(start, end))
    ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
    .watch();
}
```

- [ ] **Step 2: Commit changes**

```bash
git add lib/database/drift_database.dart
git commit -m "feat: add watchFilteredOrders to database"
```

---

### Task 2: Implement Admin Filter Providers

**Files:**
- Modify: `lib/providers/admin_provider.dart`

- [ ] **Step 1: Define Filter State and Providers**

```dart
// lib/providers/admin_provider.dart

class AdminOrderFilter {
  final DateTime start;
  final DateTime end;
  final String label;

  AdminOrderFilter({required this.start, required this.end, this.label = 'Custom'});
}

final adminOrderFilterProvider = StateProvider<AdminOrderFilter>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return AdminOrderFilter(
    start: today,
    end: today.add(const Duration(days: 1)),
    label: 'Today',
  );
});

final filteredOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final filter = ref.watch(adminOrderFilterProvider);
  final db = ref.watch(databaseProvider);
  return db.watchFilteredOrders(filter.start, filter.end);
});
```

- [ ] **Step 2: Commit changes**

```bash
git add lib/providers/admin_provider.dart
git commit -m "feat: add admin filter providers"
```

---

### Task 3: Create Order Filter Sidebar

**Files:**
- Create: `lib/widgets/admin/order_filter_sidebar.dart`

- [ ] **Step 1: Implement Sidebar Widget**

```dart
// lib/widgets/admin/order_filter_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../theme/binance_theme.dart';

class OrderFilterSidebar extends ConsumerWidget {
  const OrderFilterSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 200,
      color: BinanceTheme.surfaceElevatedDark,
      child: Column(
        children: [
          _filterButton(context, ref, 'Today', _getTodayRange()),
          _filterButton(context, ref, 'This Week', _getWeekRange()),
          _filterButton(context, ref, 'This Month', _getMonthRange()),
          _filterButton(context, ref, 'This Year', _getYearRange()),
          const Divider(color: BinanceTheme.surfaceCardDark),
          ListTile(
            title: const Text('Custom Range', style: TextStyle(color: BinanceTheme.primary)),
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (range != null) {
                ref.read(adminOrderFilterProvider.notifier).state = AdminOrderFilter(
                  start: range.start,
                  end: range.end.add(const Duration(days: 1)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _filterButton(BuildContext context, WidgetRef ref, String label, AdminOrderFilter range) {
    final isSelected = ref.watch(adminOrderFilterProvider).label == label;
    return ListTile(
      title: Text(label, style: TextStyle(color: isSelected ? BinanceTheme.primary : BinanceTheme.onDark)),
      onTap: () => ref.read(adminOrderFilterProvider.notifier).state = range,
    );
  }

  AdminOrderFilter _getTodayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return AdminOrderFilter(start: start, end: start.add(const Duration(days: 1)), label: 'Today');
  }

  AdminOrderFilter _getWeekRange() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final startDay = DateTime(start.year, start.month, start.day);
    return AdminOrderFilter(start: startDay, end: startDay.add(const Duration(days: 7)), label: 'This Week');
  }

  AdminOrderFilter _getMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return AdminOrderFilter(start: start, end: end, label: 'This Month');
  }

  AdminOrderFilter _getYearRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);
    return AdminOrderFilter(start: start, end: end, label: 'This Year');
  }
}
```

- [ ] **Step 2: Commit changes**

```bash
git add lib/widgets/admin/order_filter_sidebar.dart
git commit -m "feat: implement OrderFilterSidebar"
```

---

### Task 4: Implement Detailed Order Item View

**Files:**
- Create: `lib/widgets/admin/order_detail_view.dart`

- [ ] **Step 1: Implement OrderDetailView**

```dart
// lib/widgets/admin/order_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../theme/binance_theme.dart';

class OrderDetailView extends ConsumerWidget {
  final int orderId;
  const OrderDetailView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(orderItemsProvider(orderId));

    return itemsAsync.when(
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.quantity}x Product ID: ${item.productId} - ₱${item.priceAtTime}',
                  style: const TextStyle(color: BinanceTheme.onDark)),
              if (item.selectedModifiers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('Mods: ${item.selectedModifiers}', 
                      style: const TextStyle(color: BinanceTheme.muted, fontSize: 12)),
                ),
            ],
          ),
        )).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

- [ ] **Step 2: Commit changes**

```bash
git add lib/widgets/admin/order_detail_view.dart
git commit -m "feat: implement OrderDetailView"
```

---

### Task 5: Integrate Sidebar and Detailed View into Dashboard

**Files:**
- Modify: `lib/screens/admin_dashboard_screen.dart`

- [ ] **Step 1: Update Layout to include Sidebar**

```dart
// lib/screens/admin_dashboard_screen.dart

// 1. Import OrderFilterSidebar and OrderDetailView
// 2. Wrap _OrderHistoryView with a Row
// 3. Add OrderFilterSidebar as the first child
// 4. Update _OrderHistoryView to watch filteredOrdersStreamProvider
// 5. Update ExpansionTile children to include OrderDetailView
```

- [ ] **Step 2: Commit changes**

```bash
git add lib/screens/admin_dashboard_screen.dart
git commit -m "feat: integrate sidebar and detailed order view"
```
