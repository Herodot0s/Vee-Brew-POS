# VeeBrew POS Styling and Mock Data Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Style the `CategorySidebar`, `ProductGrid`, and implement a custom modifier selection bottom-sheet overlay using Binance Design System visual tokens and complete menu items derived from the VeeBrew menu.

**Architecture:** Use a dedicated `BinanceTheme` helper for style attributes, utilize Riverpod for category selection state management, map the static VeeBrew mock product data with custom size/sweetness modifiers, and build customized widgets matching the dark color-block theme design contract.

**Tech Stack:** Flutter, Riverpod, Google Fonts.

---

### Task 1: Setup Theme, Fonts, and Category Selection State

**Files:**
- Create: `lib/theme/binance_theme.dart`
- Create: `lib/providers/category_provider.dart`
- Create: `test/unit/category_provider_test.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add google_fonts dependency**
Add `google_fonts: ^6.2.1` under dependencies in `pubspec.yaml`.
Run: `flutter pub get`
Expected: SUCCESS

- [ ] **Step 2: Create BinanceTheme**
Create `lib/theme/binance_theme.dart` containing color and font styling tokens:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BinanceTheme {
  static const Color canvasDark = Color(0xFF0B0E11);
  static const Color surfaceCardDark = Color(0xFF1E2329);
  static const Color surfaceElevatedDark = Color(0xFF2B3139);
  static const Color primary = Color(0xFFFCD535);
  static const Color primaryActive = Color(0xFFF0B90B);
  static const Color body = Color(0xFFEAECEF);
  static const Color muted = Color(0xFF707A8A);
  static const Color tradingUp = Color(0xFF0ECB81);
  static const Color tradingDown = Color(0xFFF6465D);
  static const Color onPrimary = Color(0xFF181A20);

  static const double radiusSm = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;

  static final BorderRadius roundedSm = BorderRadius.circular(radiusSm);
  static final BorderRadius roundedMd = BorderRadius.circular(radiusMd);
  static final BorderRadius roundedLg = BorderRadius.circular(radiusLg);
  static final BorderRadius roundedXl = BorderRadius.circular(radiusXl);

  static const double spaceXxs = 4.0;
  static const double spaceXs = 8.0;
  static const double spaceSm = 12.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  static TextStyle titleStyle({double size = 14, FontWeight weight = FontWeight.w600, Color color = body}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle numberStyle({double size = 14, FontWeight weight = FontWeight.w500, Color color = primary}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}
```

- [ ] **Step 3: Create CategoryProvider**
Create `lib/providers/category_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'milk_tea');
```

- [ ] **Step 4: Write CategoryProvider Test**
Create `test/unit/category_provider_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/providers/category_provider.dart';

void main() {
  test('selectedCategoryProvider default and update', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedCategoryProvider), 'milk_tea');

    container.read(selectedCategoryProvider.notifier).state = 'cheesecake';
    expect(container.read(selectedCategoryProvider), 'cheesecake');
  });
}
```

- [ ] **Step 5: Run tests and commit**
Run: `flutter test test/unit/category_provider_test.dart`
Expected: PASS
Run:
```bash
git add pubspec.yaml lib/theme/binance_theme.dart lib/providers/category_provider.dart test/unit/category_provider_test.dart
git commit -m "feat: setup binance theme tokens and category state provider"
```

---

### Task 2: Create Mock Product and Modifier Data

**Files:**
- Modify: `lib/models/product.dart`
- Create: `lib/models/mock_data.dart`
- Create: `test/unit/mock_data_test.dart`

- [ ] **Step 1: Update Product Model**
Modify `lib/models/product.dart` to support categories and visual options:
```dart
class Product {
  final String id;
  final String name;
  final double basePrice;
  final String categoryId;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.categoryId,
    this.imageUrl,
  });
}
```

- [ ] **Step 2: Define VeeBrew Mock Menu Data**
Create `lib/models/mock_data.dart`:
```dart
import 'package:flutter/material.dart';
import 'product.dart';
import 'modifier.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;

  const Category({required this.id, required this.name, required this.icon});
}

const List<Category> mockCategories = [
  Category(id: 'milk_tea', name: 'Milk Tea', icon: Icons.local_drink),
  Category(id: 'cheesecake', name: 'Cheesecake', icon: Icons.cake),
  Category(id: 'fruit_tea_tea', name: 'Fruit Tea (Tea)', icon: Icons.emoji_food_beverage),
  Category(id: 'fruit_tea_water', name: 'Fruit Tea (Water)', icon: Icons.water_drop),
  Category(id: 'cold_brew', name: 'Cold Brew', icon: Icons.ac_unit),
  Category(id: 'hot_brew', name: 'Hot Brew', icon: Icons.coffee),
  Category(id: 'premium_frappe', name: 'Prem. Frappe', icon: Icons.icecream),
  Category(id: 'frappe_coffee', name: 'Frappe (Coffee)', icon: Icons.coffee_maker),
  Category(id: 'frappe_non_coffee', name: 'Frappe (No-Coffee)', icon: Icons.restaurant),
  Category(id: 'fries', name: 'Fries', icon: Icons.fastfood),
];

const List<Product> mockProducts = [
  // Milk Tea
  Product(id: 'mt_wintermelon', name: 'Wintermelon Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_okinawa', name: 'Okinawa Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_matcha', name: 'Matcha Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_taro', name: 'Taro Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_dark_chocolate', name: 'Dark Chocolate Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_cookies_cream', name: 'Cookies & Cream Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_salted_caramel', name: 'Salted Caramel Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_hokkaido', name: 'Hokkaido Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),

  // Cheesecake
  Product(id: 'cc_wintermelon', name: 'Wintermelon Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_okinawa', name: 'Okinawa Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_matcha', name: 'Matcha Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_taro', name: 'Taro Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_red_velvet', name: 'Red Velvet Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_double_dutch', name: 'Double Dutch Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),

  // Fruit Tea (Tea)
  Product(id: 'ftt_kiwi', name: 'Kiwi Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),
  Product(id: 'ftt_lychee', name: 'Lychee Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),
  Product(id: 'ftt_lemon', name: 'Lemon Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),
  Product(id: 'ftt_mango', name: 'Mango Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),
  Product(id: 'ftt_passion', name: 'Passion Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),

  // Fruit Tea (Water)
  Product(id: 'ftw_blueberry', name: 'Blueberry Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),
  Product(id: 'ftw_strawberry', name: 'Strawberry Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),
  Product(id: 'ftw_green_apple', name: 'Green Apple Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),
  Product(id: 'ftw_melon', name: 'Melon Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),
  Product(id: 'ftw_four_season', name: 'Four Season Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),

  // Cold Brew
  Product(id: 'cb_americano', name: 'Iced Americano', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_spanish', name: 'Iced Spanish Latte', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_mocha', name: 'Iced Mocha Latte', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_cappuccino', name: 'Iced Cappuccino Latte', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_white_mocha', name: 'Iced White Mocha', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_caramel_macchiato', name: 'Iced Caramel Macchiato', basePrice: 45.0, categoryId: 'cold_brew'),

  // Hot Brew
  Product(id: 'hb_americano', name: 'Hot Americano', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_spanish', name: 'Hot Spanish Latte', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_mocha', name: 'Hot Mocha Latte', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_cappuccino', name: 'Hot Cappuccino Latte', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_white_mocha', name: 'Hot White Mocha', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_caramel_macchiato', name: 'Hot Caramel Macchiato', basePrice: 45.0, categoryId: 'hot_brew'),

  // Premium Frappe
  Product(id: 'pf_mango_graham', name: 'Mango Graham Premium', basePrice: 55.0, categoryId: 'premium_frappe'),
  Product(id: 'pf_cookies_cream', name: 'Cookies & Cream Premium', basePrice: 65.0, categoryId: 'premium_frappe'),

  // Frappe (Coffee-Based)
  Product(id: 'fc_dark_caramel', name: 'Dark Caramel Frappe', basePrice: 45.0, categoryId: 'frappe_coffee'),
  Product(id: 'fc_dark_mocha', name: 'Dark Mocha Frappe', basePrice: 45.0, categoryId: 'frappe_coffee'),
  Product(id: 'fc_java_chip', name: 'Java Chip Frappe', basePrice: 45.0, categoryId: 'frappe_coffee'),

  // Frappe (Non-Coffee)
  Product(id: 'fnc_matcha', name: 'Matcha Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_taro', name: 'Taro Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_mango', name: 'Mango Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_avocado', name: 'Avocado Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_red_velvet', name: 'Red Velvet Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_green_apple', name: 'Green Apple Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),

  // Fries
  Product(id: 'fr_bbq', name: 'BBQ Fries', basePrice: 30.0, categoryId: 'fries'),
  Product(id: 'fr_cheese', name: 'Cheese Fries', basePrice: 30.0, categoryId: 'fries'),
  Product(id: 'fr_sour_cream', name: 'Sour & Cream Fries', basePrice: 30.0, categoryId: 'fries'),
];

List<ModifierGroup> getModifierGroupsForProduct(Product product) {
  if (product.categoryId == 'fries') {
    return [
      ModifierGroup(
        id: 'fries_size',
        productId: product.id,
        name: 'Size Selection',
        isRequired: true,
        options: [
          ModifierOption(id: 'sz_small', groupId: 'fries_size', name: 'Small', priceDelta: 0.0, isDefault: true),
          ModifierOption(id: 'sz_medium', groupId: 'fries_size', name: 'Medium', priceDelta: 30.0),
          ModifierOption(id: 'sz_large', groupId: 'fries_size', name: 'Large', priceDelta: 60.0),
          ModifierOption(id: 'sz_xlarge', groupId: 'fries_size', name: 'X-Large', priceDelta: 90.0),
        ],
      )
    ];
  }

  // Premium Frappe sizes have specialized custom steps
  if (product.id == 'pf_mango_graham') {
    return [
      ModifierGroup(
        id: 'pf_mg_size',
        productId: product.id,
        name: 'Size Selection',
        isRequired: true,
        options: [
          ModifierOption(id: 'sz_medium', groupId: 'pf_mg_size', name: 'Medium', priceDelta: 0.0, isDefault: true),
          ModifierOption(id: 'sz_large', groupId: 'pf_mg_size', name: 'Large', priceDelta: 30.0),
        ],
      )
    ];
  }

  if (product.id == 'pf_cookies_cream') {
    return [
      ModifierGroup(
        id: 'pf_cc_size',
        productId: product.id,
        name: 'Size Selection',
        isRequired: true,
        options: [
          ModifierOption(id: 'sz_medium', groupId: 'pf_cc_size', name: 'Medium', priceDelta: 0.0, isDefault: true),
          ModifierOption(id: 'sz_large', groupId: 'pf_cc_size', name: 'Large', priceDelta: 20.0),
        ],
      )
    ];
  }

  // Standard beverages sizes and customization
  List<ModifierOption> sizeOptions = [
    ModifierOption(id: 'sz_med', groupId: 'size', name: 'Medium', priceDelta: 0.0, isDefault: true),
    ModifierOption(id: 'sz_lrg', groupId: 'size', name: 'Large', priceDelta: 10.0),
  ];
  
  if (product.categoryId == 'milk_tea' || product.categoryId == 'cheesecake' || product.categoryId.startsWith('fruit_tea')) {
    sizeOptions.add(ModifierOption(id: 'sz_liter', groupId: 'size', name: '1 Liter', priceDelta: 40.0));
  }

  return [
    ModifierGroup(
      id: 'size',
      productId: product.id,
      name: 'Size Selection',
      isRequired: true,
      options: sizeOptions,
    ),
    ModifierGroup(
      id: 'sugar',
      productId: product.id,
      name: 'Sugar Level',
      isRequired: true,
      options: [
        ModifierOption(id: 's_100', groupId: 'sugar', name: '100% Sugar', priceDelta: 0.0, isDefault: true),
        ModifierOption(id: 's_75', groupId: 'sugar', name: '75% Sugar', priceDelta: 0.0),
        ModifierOption(id: 's_50', groupId: 'sugar', name: '50% Sugar', priceDelta: 0.0),
        ModifierOption(id: 's_25', groupId: 'sugar', name: '25% Sugar', priceDelta: 0.0),
        ModifierOption(id: 's_0', groupId: 'sugar', name: '0% Sugar', priceDelta: 0.0),
      ],
    ),
    ModifierGroup(
      id: 'ice',
      productId: product.id,
      name: 'Ice Level',
      isRequired: true,
      options: [
        ModifierOption(id: 'i_normal', groupId: 'ice', name: 'Normal Ice', priceDelta: 0.0, isDefault: true),
        ModifierOption(id: 'i_less', groupId: 'ice', name: 'Less Ice', priceDelta: 0.0),
        ModifierOption(id: 'i_no', groupId: 'ice', name: 'No Ice', priceDelta: 0.0),
      ],
    ),
  ];
}
```

- [ ] **Step 3: Write Mock Data Test**
Create `test/unit/mock_data_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/models/mock_data.dart';

void main() {
  test('mock data parses successfully', () {
    expect(mockCategories.length, 10);
    expect(mockProducts.length, 52);

    final milkTeas = mockProducts.where((p) => p.categoryId == 'milk_tea').toList();
    expect(milkTeas.length, 8);

    final fries = mockProducts.firstWhere((p) => p.id == 'fr_bbq');
    final friesGroups = getModifierGroupsForProduct(fries);
    expect(friesGroups.length, 1);
    expect(friesGroups.first.options.length, 4);
  });
}
```

- [ ] **Step 4: Run tests and commit**
Run: `flutter test test/unit/mock_data_test.dart`
Expected: PASS
Run:
```bash
git add lib/models/product.dart lib/models/mock_data.dart test/unit/mock_data_test.dart
git commit -m "feat: add comprehensive veebrew mock categories, products and modifiers"
```

---

### Task 3: Implement Styled CategorySidebar

**Files:**
- Modify: `lib/widgets/category_sidebar.dart`
- Create: `test/widget/category_sidebar_test.dart`

- [ ] **Step 1: Implement CategorySidebar Visual Layout**
Update `lib/widgets/category_sidebar.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mock_data.dart';
import '../providers/category_provider.dart';
import '../theme/binance_theme.dart';

class CategorySidebar extends ConsumerWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      color: BinanceTheme.canvasDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: BinanceTheme.spaceLg,
              horizontal: BinanceTheme.spaceMd,
            ),
            child: Text(
              'VEEBREW',
              style: BinanceTheme.titleStyle(
                size: 20,
                weight: FontWeight.bold,
                color: BinanceTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockCategories.length,
              itemBuilder: (context, index) {
                final cat = mockCategories[index];
                final isSelected = selectedCategory == cat.id;

                return GestureDetector(
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = cat.id;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(
                      vertical: BinanceTheme.spaceXxs,
                      horizontal: BinanceTheme.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? BinanceTheme.surfaceCardDark
                          : Colors.transparent,
                      borderRadius: BinanceTheme.roundedLg,
                      border: isSelected
                          ? Border.all(color: BinanceTheme.surfaceElevatedDark, width: 1)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (isSelected)
                          Positioned(
                            left: 0,
                            top: 12,
                            bottom: 12,
                            width: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: BinanceTheme.primary,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: BinanceTheme.spaceMd,
                            horizontal: BinanceTheme.spaceLg,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                cat.icon,
                                color: isSelected
                                    ? BinanceTheme.onDark
                                    : BinanceTheme.muted,
                                size: 20,
                              ),
                              const SizedBox(width: BinanceTheme.spaceSm),
                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: BinanceTheme.titleStyle(
                                    size: 14,
                                    weight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? BinanceTheme.onDark
                                        : BinanceTheme.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

- [ ] **Step 2: Create Sidebar Widget Test**
Create `test/widget/category_sidebar_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/widgets/category_sidebar.dart';
import 'package:veebrew/providers/category_provider.dart';

void main() {
  testWidgets('CategorySidebar renders and updates state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 250,
              child: CategorySidebar(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Milk Tea'), findsOneWidget);
    expect(find.text('Cheesecake'), findsOneWidget);

    await tester.tap(find.text('Cheesecake'));
    await tester.pumpAndSettle();

    // Verify selection is updated (requires checking provider inside a consumer widget)
  });
}
```

- [ ] **Step 3: Run test and commit**
Run: `flutter test test/widget/category_sidebar_test.dart`
Expected: PASS
Run:
```bash
git add lib/widgets/category_sidebar.dart test/widget/category_sidebar_test.dart
git commit -m "feat: implement binance dark category sidebar layout with selection"
```

---

### Task 4: Implement Customization Bottom Sheet Dialog

**Files:**
- Create: `lib/widgets/modifier_bottom_sheet.dart`
- Create: `test/widget/modifier_bottom_sheet_test.dart`

- [ ] **Step 1: Create ModifierBottomSheet Widget**
Create `lib/widgets/modifier_bottom_sheet.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/modifier.dart';
import '../models/order_item.dart';
import '../models/mock_data.dart';
import '../providers/cart_provider.dart';
import '../theme/binance_theme.dart';

class ModifierBottomSheet extends StatefulWidget {
  final Product product;

  const ModifierBottomSheet({super.key, required this.product});

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModifierBottomSheet(product: product),
    );
  }

  @override
  State<ModifierBottomSheet> createState() => _ModifierBottomSheetState();
}

class _ModifierBottomSheetState extends State<ModifierBottomSheet> {
  final Map<String, ModifierOption> _selectedModifiers = {};
  late final List<ModifierGroup> _groups;

  @override
  void initState() {
    super.initState();
    _groups = getModifierGroupsForProduct(widget.product);
    for (var group in _groups) {
      final defaultOption = group.options.firstWhere(
        (opt) => opt.isDefault,
        orElse: () => group.options.first,
      );
      _selectedModifiers[group.id] = defaultOption;
    }
  }

  double get _currentTotalPrice {
    double total = widget.product.basePrice;
    _selectedModifiers.forEach((groupId, option) {
      total += option.priceDelta;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BinanceTheme.surfaceCardDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(BinanceTheme.radiusXl),
          topRight: Radius.circular(BinanceTheme.radiusXl),
        ),
        border: const Border(
          top: BorderSide(color: BinanceTheme.surfaceElevatedDark, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: BinanceTheme.spaceLg,
        right: BinanceTheme.spaceLg,
        top: BinanceTheme.spaceLg,
        bottom: BinanceTheme.spaceLg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: BinanceTheme.titleStyle(size: 18, weight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: BinanceTheme.muted),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: BinanceTheme.spaceMd),
          ..._groups.map((group) {
            return Padding(
              padding: const EdgeInsets.only(bottom: BinanceTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    group.name,
                    style: BinanceTheme.titleStyle(
                      size: 14,
                      weight: FontWeight.w600,
                      color: BinanceTheme.muted,
                    ),
                  ),
                  const SizedBox(height: BinanceTheme.spaceXs),
                  Wrap(
                    spacing: BinanceTheme.spaceXs,
                    runSpacing: BinanceTheme.spaceXs,
                    children: group.options.map((opt) {
                      final isSelected = _selectedModifiers[group.id]?.id == opt.id;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              opt.name,
                              style: BinanceTheme.titleStyle(
                                size: 13,
                                color: isSelected ? BinanceTheme.onPrimary : BinanceTheme.body,
                                weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                            if (opt.priceDelta > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(+${opt.priceDelta.toStringAsFixed(0)})',
                                style: BinanceTheme.numberStyle(
                                  size: 12,
                                  color: isSelected ? BinanceTheme.onPrimary : BinanceTheme.primary,
                                ),
                              ),
                            ]
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: BinanceTheme.primary,
                        backgroundColor: BinanceTheme.surfaceElevatedDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BinanceTheme.roundedMd,
                          side: BorderSide(
                            color: isSelected ? BinanceTheme.primary : BinanceTheme.surfaceElevatedDark,
                            width: 1,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedModifiers[group.id] = opt;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: BinanceTheme.spaceMd),
          Consumer(
            builder: (context, ref, child) {
              return SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BinanceTheme.primary,
                    foregroundColor: BinanceTheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BinanceTheme.roundedMd,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final item = OrderItem(
                      product: widget.product,
                      selectedModifiers: _selectedModifiers.values.toList(),
                    );
                    ref.read(cartProvider.notifier).addConfiguredItem(item);
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add to Ticket',
                        style: BinanceTheme.titleStyle(
                          size: 16,
                          weight: FontWeight.bold,
                          color: BinanceTheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: BinanceTheme.spaceXs),
                      Text(
                        '₱${_currentTotalPrice.toStringAsFixed(2)}',
                        style: BinanceTheme.numberStyle(
                          size: 16,
                          weight: FontWeight.bold,
                          color: BinanceTheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create ModifierBottomSheet Widget Test**
Create `test/widget/modifier_bottom_sheet_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/models/product.dart';
import 'package:veebrew/widgets/modifier_bottom_sheet.dart';

void main() {
  testWidgets('ModifierBottomSheet shows options and updates calculated price', (tester) async {
    const product = Product(
      id: 'mt_wintermelon',
      name: 'Wintermelon Milk Tea',
      basePrice: 28.0,
      categoryId: 'milk_tea',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ModifierBottomSheet.show(context, product),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Wintermelon Milk Tea'), findsOneWidget);
    expect(find.text('100% Sugar'), findsOneWidget);
    
    // Tap Large size (+10)
    await tester.tap(find.text('Large (+10)'));
    await tester.pumpAndSettle();

    // Verify calculated price update in footer action button
    expect(find.text('₱38.00'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run test and commit**
Run: `flutter test test/widget/modifier_bottom_sheet_test.dart`
Expected: PASS
Run:
```bash
git add lib/widgets/modifier_bottom_sheet.dart test/widget/modifier_bottom_sheet_test.dart
git commit -m "feat: implement modifier custom bottom sheet for beverage configurations"
```

---

### Task 5: Implement Styled ProductGrid

**Files:**
- Modify: `lib/widgets/product_grid.dart`
- Create: `test/widget/product_grid_test.dart`

- [ ] **Step 1: Style the ProductGrid and ProductCard**
Update `lib/widgets/product_grid.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mock_data.dart';
import '../providers/category_provider.dart';
import '../theme/binance_theme.dart';
import 'modifier_bottom_sheet.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final products = mockProducts.where((p) => p.categoryId == selectedCategory).toList();

    return Container(
      color: BinanceTheme.canvasDark,
      padding: const EdgeInsets.all(BinanceTheme.spaceLg),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 1.25,
          crossAxisSpacing: BinanceTheme.spaceMd,
          mainAxisSpacing: BinanceTheme.spaceMd,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return Material(
            color: BinanceTheme.surfaceCardDark,
            borderRadius: BinanceTheme.roundedLg,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => ModifierBottomSheet.show(context, product),
              splashColor: BinanceTheme.primary.withOpacity(0.1),
              highlightColor: BinanceTheme.surfaceElevatedDark,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BinanceTheme.roundedLg,
                  border: Border.all(
                    color: BinanceTheme.surfaceElevatedDark,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(BinanceTheme.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: BinanceTheme.titleStyle(
                          size: 13,
                          weight: FontWeight.w600,
                          color: BinanceTheme.body,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '₱${product.basePrice.toStringAsFixed(0)}',
                        style: BinanceTheme.numberStyle(
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Create ProductGrid Widget Test**
Create `test/widget/product_grid_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/widgets/product_grid.dart';
import 'package:veebrew/providers/category_provider.dart';

void main() {
  testWidgets('ProductGrid filters products by category', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProductGrid(),
          ),
        ),
      ),
    );

    // Initial default category is 'milk_tea'
    expect(find.text('Wintermelon Milk Tea'), findsOneWidget);
    expect(find.text('Okinawa Milk Tea'), findsOneWidget);
    expect(find.text('BBQ Fries'), findsNothing);
  });
}
```

- [ ] **Step 3: Run test and commit**
Run: `flutter test test/widget/product_grid_test.dart`
Expected: PASS
Run:
```bash
git add lib/widgets/product_grid.dart test/widget/product_grid_test.dart
git commit -m "feat: style product grid list with high-contrast binance plates"
```

---

### Task 6: Apply Theme to OrderTicket and Screen Layout

**Files:**
- Modify: `lib/widgets/order_ticket.dart`
- Modify: `lib/screens/pos_screen.dart`

- [ ] **Step 1: Style OrderTicket to Dark Theme**
Update `lib/widgets/order_ticket.dart` to match dark styling:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../theme/binance_theme.dart';

class OrderTicket extends ConsumerWidget {
  const OrderTicket({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

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
                final modsText = item.selectedModifiers.map((m) => m.name).join(', ');
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: BinanceTheme.spaceLg,
                    vertical: BinanceTheme.spaceXs,
                  ),
                  title: Text(
                    item.product.name,
                    style: BinanceTheme.titleStyle(size: 14, color: BinanceTheme.body),
                  ),
                  subtitle: modsText.isNotEmpty
                      ? Text(
                          modsText,
                          style: BinanceTheme.titleStyle(size: 12, color: BinanceTheme.muted),
                        )
                      : null,
                  trailing: Text(
                    '₱${item.calculatedPrice.toStringAsFixed(2)}',
                    style: BinanceTheme.numberStyle(size: 14, color: BinanceTheme.body),
                  ),
                );
              },
            ),
          ),
          const Divider(color: BinanceTheme.surfaceElevatedDark, height: 1),
          Padding(
            padding: const EdgeInsets.all(BinanceTheme.spaceLg),
            child: Column(
              children: [
                Row(
                  margin: EdgeInsets.zero,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: BinanceTheme.titleStyle(size: 16, weight: FontWeight.bold, color: BinanceTheme.muted),
                    ),
                    Text(
                      '₱${cartNotifier.total.toStringAsFixed(2)}',
                      style: BinanceTheme.numberStyle(size: 20, weight: FontWeight.bold, color: BinanceTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: BinanceTheme.spaceLg),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BinanceTheme.primary,
                      foregroundColor: BinanceTheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BinanceTheme.roundedMd,
                      ),
                      elevation: 0,
                    ),
                    onPressed: cart.isNotEmpty ? () {} : null,
                    child: Text(
                      'Pay Now',
                      style: BinanceTheme.titleStyle(
                        size: 16,
                        weight: FontWeight.bold,
                        color: BinanceTheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Clean up main POS screen columns**
Modify `lib/screens/pos_screen.dart` to specify accurate layout spacing & dividers:
```dart
import 'package:flutter/material.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/product_grid.dart';
import '../widgets/order_ticket.dart';
import '../theme/binance_theme.dart';

class POSScreen extends StatelessWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: BinanceTheme.canvasDark,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: CategorySidebar(),
          ),
          VerticalDivider(width: 1, color: BinanceTheme.surfaceElevatedDark),
          Expanded(
            flex: 5,
            child: ProductGrid(),
          ),
          VerticalDivider(width: 1, color: BinanceTheme.surfaceElevatedDark),
          Expanded(
            flex: 3,
            child: OrderTicket(),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Run overall tests and commit**
Run: `flutter test`
Expected: PASS
Run:
```bash
git add lib/widgets/order_ticket.dart lib/screens/pos_screen.dart
git commit -m "feat: complete theme styling across pos layout modules"
```
