# Veebrew POS Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize the Flutter project, set up the data models, Riverpod state management, and the basic left-navigation layout shell.

**Architecture:** A Flutter app using Riverpod for state and Drift for the offline-first SQLite database. The UI will follow a fixed 3-column layout (Categories, Products, Order Ticket).

**Tech Stack:** Flutter, Riverpod, Drift (SQLite), Freezed (for models).

---

### Task 1: Scaffold Flutter Project and Add Dependencies

**Files:**
- Create: `pubspec.yaml` (modified from generated)

- [ ] **Step 1: Create the Flutter project**

Run: `flutter create . --platforms android --org com.veebrew`
Expected: SUCCESS

- [ ] **Step 2: Add core dependencies**

Run: 
```bash
flutter pub add flutter_riverpod riverpod_annotation drift sqlite3_flutter_libs path_provider path
flutter pub add --dev build_runner riverpod_generator drift_dev
```
Expected: SUCCESS

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "chore: initialize flutter project and add dependencies"
```

### Task 2: Create Core Data Models

**Files:**
- Create: `lib/models/product.dart`
- Create: `lib/models/modifier.dart`
- Create: `lib/models/order_item.dart`

- [ ] **Step 1: Create Product model**

```dart
// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double basePrice;
  final String categoryId;

  const Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.categoryId,
  });
}
```

- [ ] **Step 2: Create Modifier models**

```dart
// lib/models/modifier.dart
class ModifierGroup {
  final String id;
  final String productId;
  final String name;
  final bool isRequired;
  final bool isMultiSelect;
  final List<ModifierOption> options;

  const ModifierGroup({
    required this.id,
    required this.productId,
    required this.name,
    this.isRequired = false,
    this.isMultiSelect = false,
    required this.options,
  });
}

class ModifierOption {
  final String id;
  final String groupId;
  final String name;
  final double priceDelta;
  final bool isDefault;

  const ModifierOption({
    required this.id,
    required this.groupId,
    required this.name,
    this.priceDelta = 0.0,
    this.isDefault = false,
  });
}
```

- [ ] **Step 3: Create OrderItem model**

```dart
// lib/models/order_item.dart
import 'product.dart';
import 'modifier.dart';

class OrderItem {
  final Product product;
  final List<ModifierOption> selectedModifiers;

  const OrderItem({
    required this.product,
    required this.selectedModifiers,
  });

  double get calculatedPrice {
    double total = product.basePrice;
    for (var mod in selectedModifiers) {
      total += mod.priceDelta;
    }
    return total;
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/models/
git commit -m "feat: add core data models"
```

### Task 3: Implement Cart State with Riverpod

**Files:**
- Create: `lib/providers/cart_provider.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Create Cart Provider**

```dart
// lib/providers/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_item.dart';
import '../models/product.dart';

class CartNotifier extends StateNotifier<List<OrderItem>> {
  CartNotifier() : super([]);

  void addQuickTap(Product product) {
    state = [...state, OrderItem(product: product, selectedModifiers: [])];
  }

  void addConfiguredItem(OrderItem item) {
    state = [...state, item];
  }

  void clearCart() {
    state = [];
  }

  double get total {
    return state.fold(0, (sum, item) => sum + item.calculatedPrice);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<OrderItem>>((ref) {
  return CartNotifier();
});
```

- [ ] **Step 2: Wrap App in ProviderScope**

Modify `lib/main.dart` to wrap the app:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/pos_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VeebrewApp(),
    ),
  );
}

class VeebrewApp extends StatelessWidget {
  const VeebrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veebrew POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const POSScreen(),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/providers/ lib/main.dart
git commit -m "feat: implement cart state with riverpod"
```

### Task 4: Scaffold the 3-Column UI Layout

**Files:**
- Create: `lib/screens/pos_screen.dart`
- Create: `lib/widgets/category_sidebar.dart`
- Create: `lib/widgets/product_grid.dart`
- Create: `lib/widgets/order_ticket.dart`

- [ ] **Step 1: Create placeholder widgets**

```dart
// lib/widgets/category_sidebar.dart
import 'package:flutter/material.dart';

class CategorySidebar extends StatelessWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Text('Categories')),
    );
  }
}
```

```dart
// lib/widgets/product_grid.dart
import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(child: Text('Products')),
    );
  }
}
```

```dart
// lib/widgets/order_ticket.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class OrderTicket extends ConsumerWidget {
  const OrderTicket({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Current Order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  title: Text(item.product.name),
                  trailing: Text('\$${item.calculatedPrice.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('\$${cartNotifier.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Pay'
, style: TextStyle(fontSize: 20)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create Main POS Screen**

```dart
// lib/screens/pos_screen.dart
import 'package:flutter/material.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/product_grid.dart';
import '../widgets/order_ticket.dart';

class POSScreen extends StatelessWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            flex: 2,
            child: CategorySidebar(),
          ),
          const VerticalDivider(width: 1),
          const Expanded(
            flex: 5,
            child: ProductGrid(),
          ),
          const VerticalDivider(width: 1),
          const Expanded(
            flex: 3,
            child: OrderTicket(),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/screens/ lib/widgets/
git commit -m "feat: scaffold 3-column UI layout"
```
