# POS Panel Category Prefix and Compact Receipt Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add category name prefix to the POS order list panel items and simplify the printed receipt layout while fixing the date/order number overlap issue.

**Architecture:** Use Riverpod to watch `categoriesStreamProvider` in the `OrderTicket` widget, find the category corresponding to each cart item's product, and prefix it. Update `ReceiptGenerator` to format date and order number on separate lines and remove the store address. Write unit/widget tests for both components to verify correctness.

**Tech Stack:** Flutter, Riverpod, Drift (SQLite), esc_pos_utils_plus

---

### Task 1: POS Order Ticket Panel Category Prefix

**Files:**
- Modify: `lib/widgets/order_ticket.dart`
- Create: `test/widget/order_ticket_test.dart`

- [ ] **Step 1: Write the failing widget test**
  Create `test/widget/order_ticket_test.dart` with a test that populates the cart with a mock product under the `milk_tea` category and verifies that the text `[Milk Tea] Classic Milk Tea` is displayed on the screen.

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:veebrew/widgets/order_ticket.dart';
  import 'package:veebrew/providers/cart_provider.dart';
  import 'package:veebrew/providers/database_provider.dart';
  import 'package:veebrew/database/drift_database.dart';
  import 'package:veebrew/models/product.dart';

  void main() {
    testWidgets('OrderTicket shows product name with category prefix', (WidgetTester tester) async {
      final db = AppDatabase.memory();
      await db.seedInitialData();

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      const testProduct = Product(
        id: 'mt_wintermelon',
        name: 'Wintermelon Milk Tea',
        basePrice: 28.0,
        categoryId: 'milk_tea',
      );

      container.read(cartProvider.notifier).addQuickTap(testProduct);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: OrderTicket()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('[Milk Tea] Wintermelon Milk Tea'), findsOneWidget);

      await db.close();
    });
  }
  ```

- [ ] **Step 2: Run the test to verify it fails**
  Run: `flutter test test/widget/order_ticket_test.dart`
  Expected: FAIL (finding 'Wintermelon Milk Tea' instead of '[Milk Tea] Wintermelon Milk Tea')

- [ ] **Step 3: Implement category prefix in OrderTicket**
  Modify `lib/widgets/order_ticket.dart` to fetch categories from `categoriesStreamProvider`, lookup the matching category for each product, and prefix it to the displayed product name.

  ```dart
  // Import the data provider
  import '../providers/data_providers.dart';
  import '../database/drift_database.dart' as db_model; // to reference Category model if name collides

  // Inside Widget build:
  final categoriesAsync = ref.watch(categoriesStreamProvider);
  final categories = categoriesAsync.value ?? [];

  // Inside ListView.separated itemBuilder:
  final item = cart[index];
  final category = categories.firstWhere(
    (c) => c.id == item.product.categoryId,
    orElse: () => const db_model.Category(id: '', name: 'Unknown', sortOrder: 0),
  );

  // In the title field of ListTile:
  title: Text(
    '[${category.name}] ${item.product.name}',
    style: BinanceTheme.titleStyle(
      size: 14,
      color: BinanceTheme.body,
    ),
  ),
  ```

- [ ] **Step 4: Run the test to verify it passes**
  Run: `flutter test test/widget/order_ticket_test.dart`
  Expected: PASS

- [ ] **Step 5: Commit**
  Run:
  ```bash
  git add lib/widgets/order_ticket.dart test/widget/order_ticket_test.dart
  git commit -m "feat: show category prefix in POS order ticket panel"
  ```

---

### Task 2: Receipt Generator Simplification & Fix

**Files:**
- Modify: `lib/services/receipt_generator.dart`
- Create: `test/unit/receipt_generator_test.dart`

- [ ] **Step 1: Write the failing unit test**
  Create `test/unit/receipt_generator_test.dart` to verify that `ReceiptGenerator` output does not contain the store address and has the date and order number on separate lines.

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:veebrew/services/receipt_generator.dart';
  import 'package:veebrew/models/order_item.dart';
  import 'package:veebrew/models/product.dart';

  void main() {
    test('ReceiptGenerator generates bytes without store address and has split date/order', () async {
      final items = [
        const OrderItem(
          product: Product(
            id: 'mt_wintermelon',
            name: 'Wintermelon Milk Tea',
            basePrice: 28.0,
            categoryId: 'milk_tea',
          ),
          selectedModifiers: [],
        ),
      ];

      final bytes = await ReceiptGenerator.generateBytes('VEE-1001', items, 28.0);
      final receiptText = String.fromCharCodes(bytes);

      // Verify address lines are removed
      expect(receiptText.contains('Nueva Ecija Street'), isFalse);
      expect(receiptText.contains('Magsaysay Bago bantay'), isFalse);

      // Verify social media is kept
      expect(receiptText.contains('FB Page: veebrew'), isTrue);

      // Verify date and order number are on separate lines (i.e. not justified together on one line)
      expect(receiptText.contains('DATE:'), isTrue);
      expect(receiptText.contains('ORDER NO:'), isTrue);
      // Confirms date and order no do not appear on the same line (separated by spaces/justified)
      // They should be separate lines
      final lines = receiptText.split('\n');
      final hasCombinedLine = lines.any((l) => l.contains('DATE:') && l.contains('ORDER NO:'));
      expect(hasCombinedLine, isFalse, reason: 'Date and Order No should be on separate lines');
    });
  }
  ```

- [ ] **Step 2: Run the test to verify it fails**
  Run: `flutter test test/unit/receipt_generator_test.dart`
  Expected: FAIL

- [ ] **Step 3: Modify ReceiptGenerator**
  Update `lib/services/receipt_generator.dart` to remove the address lines and split the date/order number onto two lines.

  ```dart
  // Remove lines 57-61:
  // bytes += generator.text("15 Nueva Ecija Street, Barangay Ramon", ...
  // bytes += generator.text("Magsaysay Bago bantay QC", ...

  // Replace lines 68-73:
  // final dateStr = "DATE: ${_formatDateTime(DateTime.now())}";
  // final orderStr = "ORDER NO: $orderNumber";
  // bytes += generator.text(justify(dateStr, orderStr, width: width), ...
  // With:
  bytes += generator.text("DATE: ${_formatDateTime(DateTime.now())}",
      styles: const PosStyles(align: PosAlign.left));
  bytes += generator.text("ORDER NO: $orderNumber",
      styles: const PosStyles(align: PosAlign.left));
  ```

- [ ] **Step 4: Run the test to verify it passes**
  Run: `flutter test test/unit/receipt_generator_test.dart`
  Expected: PASS

- [ ] **Step 5: Run all project tests to ensure no regressions**
  Run: `flutter test`
  Expected: PASS (all tests pass)

- [ ] **Step 6: Commit**
  Run:
  ```bash
  git add lib/services/receipt_generator.dart test/unit/receipt_generator_test.dart
  git commit -m "feat: simplify receipt contents and split date and order number lines"
  ```
