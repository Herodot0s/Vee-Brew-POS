# Design Spec: Analytics Date Range & Order Detail Expansion

## 1. Context & Goal
Modify POS dashboard analytics view to allow custom date/date range selection, and enhance the order history screen to show order items, selected modifiers, and order timestamp in 12-hour format inside the expanded tile (dropdown).

---

## 2. Technical Design

### Analytics Date Selection
#### 1. State Notifier (`lib/providers/analytics_state_provider.dart`)
We will replace the simple `TimeRange` enum state in `AnalyticsStateNotifier` with a custom `AnalyticsFilterState` class to support presets and custom ranges.

```dart
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
}
```

Methods inside notifier:
- `setTimeRange(TimeRange range)`: Calculates preset start/end dates.
- `setCustomRange(DateTime start, DateTime end)`: Sets the range to custom.

#### 2. Query (`lib/providers/analytics_provider.dart`)
We update `analyticsSummaryProvider` to read `analyticsStateProvider` and query orders where `createdAt` is between `startDate` and `endDate`.

```dart
final filter = ref.watch(analyticsStateProvider);
// ...
query.where(
  db.orders.createdAt.isBiggerOrEqualValue(filter.startDate) &
  db.orders.createdAt.isSmallerOrEqualValue(filter.endDate)
);
```

#### 3. View UI (`lib/widgets/analytics/components/time_range_selector.dart`)
Add a custom chip to the select options. On select, show a `showDateRangePicker`.

---

### Order Detail Expansion UI
#### 1. Provider (`lib/providers/admin_provider.dart`)
Define a model class `OrderItemWithProduct` and a FutureProvider `orderItemsWithProductProvider`.

```dart
class OrderItemWithProduct {
  final OrderItem orderItem;
  final Product product;
  OrderItemWithProduct({required this.orderItem, required this.product});
}
```

```dart
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

#### 2. Expanded Detail Card UI (`lib/screens/admin_dashboard_screen.dart`)
Inside `_OrderHistoryView`:
- Display items list using `orderItemsWithProductProvider`.
- Parse modifiers JSON list and display sub-options (e.g. sugar levels, syrups).
- Add metadata summary: Placed at `12-hour formatted date/time`, payment method.
