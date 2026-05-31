# Spec: VeeBrew POS Styling and Mock Data

## Goal
Implement a high-fidelity visual interface for the VeeBrew POS app using the Binance Design System principles. The layout includes a styled `CategorySidebar` and a responsive `ProductGrid` populated with complete menu items parsed from the VeeBrew menu.

## 1. Design System & Tokens
We map the Binance Design System tokens from `Design.md` to our Flutter theme system.

### Colors
*   **Canvas Dark:** `#0B0E11` (Standard dark background for screens)
*   **Surface Card Dark:** `#1E2329` (Primary widget surfaces like sidebar items, product plates)
*   **Surface Elevated Dark:** `#2B3139` (Borders, active states, hovered items)
*   **Binance Yellow:** `#FCD535` (Accent yellow for active tabs, main CTAs)
*   **Binance Yellow Active:** `#F0B90B` (Tap/Press state for yellow elements)
*   **Ink/Text Light:** `#EAECEF` (Running text color on dark background)
*   **Text Muted:** `#707A8A` (Labels, inactive items)
*   **Trading Up:** `#0ECB81` (Green semantic accents for category filters/specials)
*   **Trading Down:** `#F6465D` (Red semantic accents for delete/void buttons)

### Typography
*   **Sans-Serif Font (Inter fallback via GoogleFonts.inter):** Used for product names, category labels, button text, and general interface labels.
*   **Tabular/Monospace Font (JetBrains Mono fallback via GoogleFonts.jetBrainsMono):** Strictly used for price indicators, subtotal listings, checkout counts, currency values, and modifier price deltas to ensure vertical alignment of numerical tabular data.

### Shapes & Spacing System
*   **Border Radius:**
    *   `roundedSm`: 4.0 (Small chips / modifiers)
    *   `roundedMd`: 6.0 (Buttons, form fields)
    *   `roundedLg`: 8.0 (Product cards, category tabs)
    *   `roundedXl`: 12.0 (Container cards, dialog overlays)
*   **Spacing Base Unit (4px multiples):**
    *   `spaceXxs`: 4.0
    *   `spaceXs`: 8.0
    *   `spaceSm`: 12.0
    *   `spaceMd`: 16.0
    *   `spaceLg`: 24.0
    *   `spaceXl`: 32.0
    *   `spaceXxl`: 48.0

---

## 2. Centralized Theme Helper (`lib/theme/binance_theme.dart`)
We define a clean token class mapping:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BinanceTheme {
  // Colors
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

  // Border Radii
  static const double radiusSm = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;

  static final BorderRadius roundedSm = BorderRadius.circular(radiusSm);
  static final BorderRadius roundedMd = BorderRadius.circular(radiusMd);
  static final BorderRadius roundedLg = BorderRadius.circular(radiusLg);
  static final BorderRadius roundedXl = BorderRadius.circular(radiusXl);

  // Spacing
  static const double spaceXxs = 4.0;
  static const double spaceXs = 8.0;
  static const double spaceSm = 12.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;

  // Typography Styles
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

## 2. Domain & Category Selection State
To enable category selection and update the product grid, we introduce a central provider in `lib/providers/category_provider.dart`.

```dart
// lib/providers/category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'milk_tea');
```

---

## 3. Product & Modifier Models Update
We extend `Product` and `ModifierOption` in `lib/models/product.dart` and `lib/models/modifier.dart` to support categories and boba-shop specific selections.

```dart
// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double basePrice;
  final String categoryId;
  final String? imageUrl; // Optional, placeholder for layout

  const Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.categoryId,
    this.imageUrl,
  });
}
```

---

## 4. VeeBrew Mock Data (`lib/models/mock_data.dart`)

### Categories
1.  `milk_tea` - Milk Tea (Base 28)
2.  `cheesecake` - Cheesecake Series (Base 43)
3.  `fruit_tea_tea` - Fruit Tea (Tea-Based) (Base 45)
4.  `fruit_tea_water` - Fruit Tea (Water-Based) (Base 35)
5.  `cold_brew` - Cold Brew (Base 45)
6.  `hot_brew` - Hot Brew (Base 45)
7.  `premium_frappe` - Premium Frappe (Base 55/65)
8.  `frappe_coffee` - Frappe (Coffee-Based) (Base 45)
9.  `frappe_non_coffee` - Frappe (Non-Coffee) (Base 45)
10. `fries` - Fries (Base 30)

### Product list
*   **Milk Tea:** Wintermelon (28.0), Okinawa (28.0), Matcha (28.0), Taro (28.0), Dark Chocolate (28.0), Cookies & Cream (28.0), Salted Caramel (28.0), Hokkaido (28.0).
*   **Cheesecake:** Wintermelon (43.0), Okinawa (43.0), Matcha (43.0), Taro (43.0), Red Velvet (43.0), Double Dutch (43.0).
*   **Fruit Tea (Tea):** Kiwi (45.0), Lychee (45.0), Lemon (45.0), Mango (45.0), Passion (45.0).
*   **Fruit Tea (Water):** Blueberry (35.0), Straw-berry (35.0), Green Apple (35.0), Melon (35.0), Four Season (35.0).
*   **Cold Brew:** Iced Americano (45.0), Spanish Latte (45.0), Mocha Latte (45.0), Cappuccino (45.0), White Mocha (45.0), Caramel Macchiato (45.0).
*   **Hot Brew:** Hot Americano (45.0), Spanish Latte (45.0), Mocha Latte (45.0), Cappuccino (45.0), White Mocha (45.0), Caramel Macchiato (45.0).
*   **Premium Frappe:** Mango Graham (55.0), Cookies & Cream (65.0).
*   **Frappe (Coffee-Based):** Dark Caramel (45.0), Dark Mocha (45.0), Java Chip (45.0).
*   **Frappe (Non-Coffee):** Matcha (45.0), Taro (45.0), Mango (45.0), Avocado (45.0), Red Velvet (45.0), Green Apple (45.0).
*   **Fries:** BBQ (30.0), Cheese (30.0), Sour & Cream (30.0).

### Modifiers
*   **Sizes:**
    *   *Standard Drinks:* Medium (+0.0), Large (+10.0), 1 Liter (+40.0)
    *   *Premium Frappe - Mango Graham:* Medium (+0.0), Large (+30.0)
    *   *Premium Frappe - Cookies & Cream:* Medium (+0.0), Large (+20.0)
    *   *Fries Size:* Small (+0.0), Medium (+30.0), Large (+60.0), X-Large (+90.0)
*   **Sweetness Levels:** 100% (Default), 75%, 50%, 25%, 0%
*   **Ice Levels:** Normal Ice (Default), Less Ice, No Ice

---

## 5. UI Layout Specifications

### Category Sidebar (`lib/widgets/category_sidebar.dart`)
*   **Width:** Fixed or 20% width.
*   **Design:** Deep near-black background (`#0B0E11`). Vertical scroll list of categories.
*   **Visual Indicators:**
    *   *Selected state:* Surface turns to `#1E2329`. Left border gets a 3px thick vertical bar in `#FCD535` (Binance Yellow). Text and icon turn high-contrast white.
    *   *Unselected state:* Transparent background, muted text and icon color (`#707A8A`).

### Product Grid (`lib/widgets/product_grid.dart`)
*   **Columns:** 3 or 4 column grid depending on available horizontal space (responsive layout).
*   **Product Card Plate:**
    *   **Background:** `#1E2329` (surface-card-dark).
    *   **Border:** 1px hairline border in `#2B3139`.
    *   **Typography:**
        *   Product title is in clean bold sans-serif text (`#EAECEF`), sized 14px. Max 2 lines.
        *   Product base price is positioned in the bottom right corner in tabular `#FCD535` yellow text using the tabular font style.
    *   **Interaction:** Tapping on a card opens the Modifier Bottom Sheet (if modifiers apply) or performs a quick-add to the Cart Provider.

### Modifier Selection Dialog / Bottom Sheet
*   **Design:** Full-width dark background bottom sheet (`#1E2329`) with `#2B3139` borders.
*   **Sections:** Segmented buttons or chips for selecting Size, Sweetness, and Ice levels.
*   **Footer Action:** A bold full-width button in `#FCD535` (Binance Yellow) with black text (`#181A20`) labeled "Add to Ticket - $Price".

---

## 6. Implementation Stages & Build Order
1.  **Stage 1:** Create `lib/theme/binance_theme.dart` and add `google_fonts` package.
2.  **Stage 2:** Set up `lib/providers/category_provider.dart` for tracking the currently selected category.
3.  **Stage 3:** Write `lib/models/mock_data.dart` holding the parsed categories, products, and standard modifier groups.
4.  **Stage 4:** Update `lib/widgets/category_sidebar.dart` to render the category list and bind selection state.
5.  **Stage 5:** Update `lib/widgets/product_grid.dart` to filter products based on selected category and style cards.
6.  **Stage 6:** Implement the modifier bottom sheet dialog for drink customization.
