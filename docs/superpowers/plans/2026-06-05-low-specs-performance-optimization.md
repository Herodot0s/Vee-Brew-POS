# Low-Specs Performance Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Optimize the application for low-spec, offline Android 5.1 devices by disabling runtime web font downloads, isolating screen regions using repaint boundaries, minimizing GPU clipping passes, and optimizing linear lookups.

**Architecture:** We will disable runtime Google Fonts web requests (forcing system fallback offline), add `RepaintBoundary` nodes to isolate sidebar, product grid, and order ticket paints, switch expensive `Clip.antiAlias` to `Clip.hardEdge`, and convert category search in `OrderTicket` to a pre-computed map.

**Tech Stack:** Flutter, Dart, Google Fonts, Drift, Riverpod

---

### Task 1: Disable Runtime Font Fetching

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Modify `lib/main.dart`**
  Add the `google_fonts` import and set `allowRuntimeFetching` to false at the start of the `main()` function.

  Replace:
  ```dart
  import 'dart:ffi';
  import 'package:sqlite3/open.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'screens/pos_screen.dart';
  import 'providers/database_provider.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    open.overrideFor(OperatingSystem.android, () {
  ```

  With:
  ```dart
  import 'dart:ffi';
  import 'package:sqlite3/open.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'screens/pos_screen.dart';
  import 'providers/database_provider.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;

    open.overrideFor(OperatingSystem.android, () {
  ```

- [ ] **Step 2: Run tests to verify startup works**
  Run: `flutter test test/widget_test.dart`
  Expected: PASS

- [ ] **Step 3: Commit**
  ```bash
  git add lib/main.dart
  git commit -m "perf: disable google fonts runtime HTTP fetching for offline performance"
  ```

---

### Task 2: Repaint Boundary Isolation

**Files:**
- Modify: `lib/screens/pos_screen.dart`

- [ ] **Step 1: Modify `lib/screens/pos_screen.dart`**
  Wrap panels inside `RepaintBoundary` to prevent full screen repaints on visual changes.

  Replace:
  ```dart
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final isAdminMode = ref.watch(isAdminModeProvider);
      return Scaffold(
        backgroundColor: BinanceTheme.canvasDark,
        body: Row(
          children: [
            const Expanded(flex: 2, child: CategorySidebar()),
            const VerticalDivider(
              width: 1,
              color: BinanceTheme.surfaceElevatedDark,
            ),
            Expanded(
              flex: 8,
              child: isAdminMode
                  ? const AdminDashboardScreen()
                  : const Row(
                      children: [
                        Expanded(flex: 5, child: ProductGrid()),
                        VerticalDivider(
                          width: 1,
                          color: BinanceTheme.surfaceElevatedDark,
                        ),
                        Expanded(flex: 3, child: OrderTicket()),
                      ],
                    ),
            ),
          ],
        ),
      );
    }
  ```

  With:
  ```dart
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final isAdminMode = ref.watch(isAdminModeProvider);
      return Scaffold(
        backgroundColor: BinanceTheme.canvasDark,
        body: Row(
          children: [
            const Expanded(
              flex: 2,
              child: RepaintBoundary(child: CategorySidebar()),
            ),
            const VerticalDivider(
              width: 1,
              color: BinanceTheme.surfaceElevatedDark,
            ),
            Expanded(
              flex: 8,
              child: isAdminMode
                  ? const RepaintBoundary(child: AdminDashboardScreen())
                  : const Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: RepaintBoundary(child: ProductGrid()),
                        ),
                        VerticalDivider(
                          width: 1,
                          color: BinanceTheme.surfaceElevatedDark,
                        ),
                        Expanded(
                          flex: 3,
                          child: RepaintBoundary(child: OrderTicket()),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    }
  ```

- [ ] **Step 2: Run tests to verify build is functional**
  Run: `flutter test test/widget_test.dart`
  Expected: PASS

- [ ] **Step 3: Commit**
  ```bash
  git add lib/screens/pos_screen.dart
  git commit -m "perf: isolate sidebar, grid, and ticket panels with RepaintBoundary"
  ```

---

### Task 3: GPU Clip Optimization

**Files:**
- Modify: `lib/widgets/product_grid.dart`
- Modify: `lib/widgets/admin/bento_card.dart`

- [ ] **Step 1: Modify `lib/widgets/product_grid.dart`**
  Replace expensive `Clip.antiAlias` with `Clip.hardEdge` on card containers.

  Replace:
  ```dart
                      return Material(
                        color: isSelected
                            ? BinanceTheme.surfaceElevatedDark
                            : BinanceTheme.surfaceCardDark,
                        borderRadius: BinanceTheme.roundedLg,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
  ```

  With:
  ```dart
                      return Material(
                        color: isSelected
                            ? BinanceTheme.surfaceElevatedDark
                            : BinanceTheme.surfaceCardDark,
                        borderRadius: BinanceTheme.roundedLg,
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
  ```

- [ ] **Step 2: Modify `lib/widgets/admin/bento_card.dart`**
  Replace expensive `Clip.antiAlias` with `Clip.hardEdge` in Bento Cards.

  Replace:
  ```dart
          child: Card(
            elevation: _isHovered ? 8 : 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
  ```

  With:
  ```dart
          child: Card(
            elevation: _isHovered ? 8 : 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
  ```

- [ ] **Step 3: Run widget tests**
  Run: `flutter test test/widget/product_grid_test.dart`
  Expected: PASS

- [ ] **Step 4: Commit**
  ```bash
  git add lib/widgets/product_grid.dart lib/widgets/admin/bento_card.dart
  git commit -m "perf: optimize GPU usage by changing clipBehavior to Clip.hardEdge"
  ```

---

### Task 4: Order Ticket Lookup Optimization

**Files:**
- Modify: `lib/widgets/order_ticket.dart`

- [ ] **Step 1: Modify `lib/widgets/order_ticket.dart`**
  Build a O(1) key lookup map for categories instead of using a linear O(N) loop during list rendering.

  Replace:
  ```dart
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final cart = ref.watch(cartProvider);
      final cartNotifier = ref.read(cartProvider.notifier);
      final categoriesAsync = ref.watch(categoriesStreamProvider);
      final categories = categoriesAsync.value ?? [];

      return Container(
        color: BinanceTheme.surfaceCardDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(BinanceTheme.spaceLg),
              child: Text(
                'Current Order',
                style: BinanceTheme.titleStyle(size: 16, weight: FontWeight.bold),
              ),
            ),
            const Divider(color: BinanceTheme.surfaceElevatedDark, height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: cart.length,
                separatorBuilder: (context, index) => const Divider(
                  color: BinanceTheme.surfaceElevatedDark,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final item = cart[index];
                  final modsText = item.selectedModifiers
                      .map((m) => m.name)
                      .join(', ');

                  Category? matchedCategory;
                  for (final c in categories) {
                    if (c.id == item.product.categoryId) {
                      matchedCategory = c;
                      break;
                    }
                  }
                  final categoryName = matchedCategory?.name ?? 'Unknown';
  ```

  With:
  ```dart
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final cart = ref.watch(cartProvider);
      final cartNotifier = ref.read(cartProvider.notifier);
      final categoriesAsync = ref.watch(categoriesStreamProvider);
      final categories = categoriesAsync.value ?? [];
      final categoryMap = {for (final c in categories) c.id: c.name};

      return Container(
        color: BinanceTheme.surfaceCardDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(BinanceTheme.spaceLg),
              child: Text(
                'Current Order',
                style: BinanceTheme.titleStyle(size: 16, weight: FontWeight.bold),
              ),
            ),
            const Divider(color: BinanceTheme.surfaceElevatedDark, height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: cart.length,
                separatorBuilder: (context, index) => const Divider(
                  color: BinanceTheme.surfaceElevatedDark,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final item = cart[index];
                  final modsText = item.selectedModifiers
                      .map((m) => m.name)
                      .join(', ');

                  final categoryName = categoryMap[item.product.categoryId] ?? 'Unknown';
  ```

- [ ] **Step 2: Run all tests to verify stability**
  Run: `flutter test`
  Expected: PASS (All tests passed)

- [ ] **Step 3: Commit**
  ```bash
  git add lib/widgets/order_ticket.dart
  git commit -m "perf: use O(1) map lookup for categories in OrderTicket"
  ```
