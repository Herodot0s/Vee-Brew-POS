# Drift Database & Checkout Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement offline-first SQLite persistence for POS mock data and orders, then build the modal checkout workflow.

**Architecture:** Drift (SQLite) database with streams feeding Riverpod providers. Modal checkout overlay creating transactional saves to the database and resetting in-memory cart state.

**Tech Stack:** Flutter, Riverpod, Drift, SQLite3.

---

### Task 1: Setup Drift Database Configuration

**Files:**
- Create: `lib/database/database.dart`
- Create: `lib/database/tables.dart`

- [ ] **Step 1: Define Table Structures**

Create `lib/database/tables.dart`:

```dart
import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get basePrice => real()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Modifiers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get priceDelta => real()();
  TextColumn get groupName => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text()();
  RealColumn get totalAmount => real()();
  TextColumn get paymentMethod => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get priceAtTime => real()();
  TextColumn get selectedModifiers => text()(); // JSON string
}
```

- [ ] **Step 2: Create Database Class**

Create `lib/database/database.dart`:

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Products, Modifiers, Orders, OrderItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
```

- [ ] **Step 3: Run Code Generation**

Run: `dart run build_runner build -d`
Expected: Succeeds and generates `lib/database/database.g.dart`.

- [ ] **Step 4: Commit**

```bash
git add lib/database/
git commit -m "feat: setup drift database tables and connection"
```

---

### Task 2: Seeding Initial Data

**Files:**
- Modify: `lib/database/database.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Add Seeding Method to Database**

Modify `lib/database/database.dart` to add a `seedInitialData` method using data from `lib/models/mock_data.dart`.

```dart
// Add import
import '../models/mock_data.dart';

// Inside AppDatabase class:
  Future<void> seedInitialData() async {
    final existingCategories = await select(categories).get();
    if (existingCategories.isNotEmpty) return; // Already seeded

    await transaction(() async {
      // 1. Seed Categories
      for (int i = 0; i < MockData.categories.length; i++) {
        final cat = MockData.categories[i];
        await into(categories).insert(
          CategoriesCompanion.insert(
            id: cat.id,
            name: cat.name,
            sortOrder: i,
          ),
        );
      }

      // 2. Seed Products
      for (final prod in MockData.products) {
        await into(products).insert(
          ProductsCompanion.insert(
            id: prod.id,
            name: prod.name,
            basePrice: prod.basePrice,
            categoryId: prod.categoryId,
            imageUrl: Value(prod.imageUrl),
          ),
        );
      }

      // 3. Seed Modifiers (Flattens out for simple table storage)
      for (final mod in MockData.modifiers) {
        for (final opt in mod.options) {
          await into(modifiers).insert(
            ModifiersCompanion.insert(
              id: opt.id,
              name: opt.name,
              priceDelta: opt.priceDelta,
              groupName: mod.id,
            ),
          );
        }
      }
    });
  }
```

- [ ] **Step 2: Initialize Provider and DB in main.dart**

Create global provider in `lib/main.dart` and seed on startup.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import 'screens/pos_screen.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  final db = container.read(databaseProvider);
  await db.seedInitialData();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const VeeBrewApp(),
    ),
  );
}

class VeeBrewApp extends StatelessWidget {
  const VeeBrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeeBrew POS',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const POSScreen(),
    );
  }
}
```

- [ ] **Step 3: Run app to verify seeding**

Run: `flutter run -d windows` (or macos/linux depending on platform)
Expected: App launches successfully without crashing, DB creates and seeds silently.

- [ ] **Step 4: Commit**

```bash
git add lib/database/database.dart lib/main.dart
git commit -m "feat: implement database seeding from mock data on startup"
```

---

### Task 3: Migrate UI to Database Streams

**Files:**
- Create: `lib/providers/data_providers.dart`
- Modify: `lib/widgets/category_sidebar.dart`
- Modify: `lib/widgets/product_grid.dart`

- [ ] **Step 1: Create Stream Providers**

Create `lib/providers/data_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../main.dart'; // For databaseProvider
import 'category_provider.dart'; // For selectedCategoryProvider
import 'package:drift/drift.dart'; // For ordering

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.categories)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  return (db.select(db.products)
        ..where((t) => t.categoryId.equals(selectedCategory)))
      .watch();
});
```

- [ ] **Step 2: Update Category Sidebar to read Stream**

Modify `lib/widgets/category_sidebar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/data_providers.dart';
import '../theme/binance_theme.dart';

class CategorySidebar extends ConsumerWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Container(
      width: 250,
      color: BinanceTheme.canvasDark,
      child: categoriesAsync.when(
        data: (categories) {
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category.id;

              return InkWell(
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state = category.id;
                },
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected ? BinanceTheme.surfaceCardDark : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isSelected ? BinanceTheme.primary : Colors.transparent,
                        width: 3.0,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: BinanceTheme.spaceMd),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    category.name,
                    style: BinanceTheme.titleStyle(
                      size: 16,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : BinanceTheme.muted,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: BinanceTheme.primary)),
        error: (err, stack) => Center(child: Text('Error loading categories', style: BinanceTheme.titleStyle())),
      ),
    );
  }
}
```

- [ ] **Step 3: Update Product Grid to read Stream**

Modify `lib/widgets/product_grid.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';
import '../theme/binance_theme.dart';
import 'modifier_bottom_sheet.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Container(
      color: BinanceTheme.canvasDark,
      padding: const EdgeInsets.all(BinanceTheme.spaceLg),
      child: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Text('No products found', style: BinanceTheme.titleStyle()),
            );
          }
          
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: BinanceTheme.spaceMd,
              crossAxisSpacing: BinanceTheme.spaceMd,
              childAspectRatio: 0.85,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return InkWell(
                onTap: () {
                  // Legacy mock usage here needs adapting in the actual app implementation,
                  // passing the DB product to the modifier sheet.
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => ModifierBottomSheet(
                       // Adapt to pass proper data here based on previous implementation
                       // Assuming product ID for now
                       productId: product.id,
                       productName: product.name,
                       basePrice: product.basePrice,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: BinanceTheme.surfaceCardDark,
                    borderRadius: BinanceTheme.roundedLg,
                    border: Border.all(color: BinanceTheme.surfaceElevatedDark),
                  ),
                  padding: const EdgeInsets.all(BinanceTheme.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: BinanceTheme.titleStyle(size: 14, color: BinanceTheme.body),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '\$${product.basePrice.toStringAsFixed(2)}',
                          style: BinanceTheme.numberStyle(size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: BinanceTheme.primary)),
        error: (err, stack) => Center(child: Text('Error loading products', style: BinanceTheme.titleStyle())),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/providers/data_providers.dart lib/widgets/category_sidebar.dart lib/widgets/product_grid.dart
git commit -m "feat: migrate sidebar and grid to drift reactive streams"
```

---

### Task 4: Checkout Save Logic & Providers

**Files:**
- Create: `lib/providers/checkout_provider.dart`

- [ ] **Step 1: Write the Database Saving Logic**

Create `lib/providers/checkout_provider.dart`. We will inject the DB and the Cart provider to execute a transaction.

```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../main.dart'; // For databaseProvider
import 'cart_provider.dart';
import 'package:intl/intl.dart';

final checkoutServiceProvider = Provider((ref) => CheckoutService(ref));

class CheckoutService {
  final Ref _ref;
  CheckoutService(this._ref);

  Future<void> processCheckout(String paymentMethod) async {
    final db = _ref.read(databaseProvider);
    final cartItems = _ref.read(cartProvider);
    final total = _ref.read(cartTotalProvider);

    if (cartItems.isEmpty) return;

    // Generate Order Number: 20260601-001 format
    final now = DateTime.now();
    final datePrefix = DateFormat('yyyyMMdd').format(now);
    
    await db.transaction(() async {
      // 1. Get daily sequence count
      final todayStart = DateTime(now.year, now.month, now.day);
      final countResult = await (db.select(db.orders)..where((t) => t.createdAt.isBiggerOrEqualValue(todayStart))).get();
      final seqNum = (countResult.length + 1).toString().padLeft(3, '0');
      final orderNumber = '$datePrefix-$seqNum';

      // 2. Insert Order
      final orderId = await db.into(db.orders).insert(
        OrdersCompanion.insert(
          orderNumber: orderNumber,
          totalAmount: total,
          paymentMethod: paymentMethod,
          createdAt: now,
        ),
      );

      // 3. Insert Items
      for (final item in cartItems) {
        final modsJson = jsonEncode(item.selectedModifiers.map((m) => {
          'id': m.id,
          'name': m.name,
          'priceDelta': m.priceDelta,
        }).toList());

        await db.into(db.orderItems).insert(
          OrderItemsCompanion.insert(
            orderId: orderId,
            productId: item.product.id,
            quantity: item.quantity,
            priceAtTime: item.unitPrice,
            selectedModifiers: modsJson,
          ),
        );
      }
    });

    // 4. Clear Cart
    _ref.read(cartProvider.notifier).clearCart();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/checkout_provider.dart
git commit -m "feat: implement database transaction for saving orders"
```

---

### Task 5: Checkout Modal UI

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/widgets/order_ticket.dart`
- Create: `lib/widgets/checkout_modal.dart`

- [ ] **Step 1: Add dependencies**

Run: `flutter pub add intl`

- [ ] **Step 2: Create Checkout Modal Dialog**

Create `lib/widgets/checkout_modal.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../theme/binance_theme.dart';

class CheckoutModal extends ConsumerStatefulWidget {
  const CheckoutModal({super.key});

  @override
  ConsumerState<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
  bool _isProcessing = false;

  Future<void> _handlePayment(String method) async {
    setState(() => _isProcessing = true);
    
    await ref.read(checkoutServiceProvider).processCheckout(method);
    
    if (!mounted) return;
    
    // Simulate brief processing time
    await Future.delayed(const Duration(milliseconds: 500));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful: $method', style: BinanceTheme.titleStyle(color: Colors.white)),
        backgroundColor: BinanceTheme.tradingUp,
        duration: const Duration(seconds: 2),
      )
    );
    
    Navigator.of(context).pop(); // Close modal
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);

    return Dialog(
      backgroundColor: BinanceTheme.surfaceCardDark,
      shape: RoundedRectangleBorder(borderRadius: BinanceTheme.roundedXl),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(BinanceTheme.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Checkout', style: BinanceTheme.titleStyle(size: 20, weight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: BinanceTheme.spaceLg),
            
            Text('Amount Due', style: BinanceTheme.titleStyle(color: BinanceTheme.muted)),
            Text('\$${total.toStringAsFixed(2)}', style: BinanceTheme.numberStyle(size: 48, color: BinanceTheme.primary)),
            
            const SizedBox(height: BinanceTheme.spaceXl),
            
            if (_isProcessing)
              const Center(child: CircularProgressIndicator(color: BinanceTheme.primary))
            else
              Row(
                children: [
                  Expanded(
                    child: _PaymentButton(
                      label: 'CASH',
                      icon: Icons.money,
                      onTap: () => _handlePayment('Cash'),
                    ),
                  ),
                  const SizedBox(width: BinanceTheme.spaceMd),
                  Expanded(
                    child: _PaymentButton(
                      label: 'CARD',
                      icon: Icons.credit_card,
                      onTap: () => _handlePayment('Card'),
                    ),
                  ),
                ],
              ),
              
            const SizedBox(height: BinanceTheme.spaceLg),
            TextButton(
              onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
              child: Text('Cancel', style: BinanceTheme.titleStyle(color: BinanceTheme.muted)),
            )
          ],
        ),
      ),
    );
  }
}

class _PaymentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PaymentButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BinanceTheme.roundedLg,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: BinanceTheme.spaceLg),
        decoration: BoxDecoration(
          border: Border.all(color: BinanceTheme.surfaceElevatedDark),
          borderRadius: BinanceTheme.roundedLg,
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: BinanceTheme.spaceXs),
            Text(label, style: BinanceTheme.titleStyle(weight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Connect to Order Ticket**

Modify `lib/widgets/order_ticket.dart` to trigger the dialog on the primary "Pay" action:

```dart
// Find the "Charge" or "Pay" button inside OrderTicket.dart
// Change its onPressed handler:
onPressed: () {
  final cart = ref.read(cartProvider);
  if (cart.isEmpty) return;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const CheckoutModal(),
  );
},
```

- [ ] **Step 4: Run application to verify checkout workflow**

Run: `flutter run -d windows`
Expected: Clicking Pay opens dialog. Clicking Cash saves to DB, clears cart, closes dialog.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml lib/widgets/checkout_modal.dart lib/widgets/order_ticket.dart
git commit -m "feat: implement checkout modal ui and trigger from order ticket"
```
