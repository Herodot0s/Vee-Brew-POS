# Design Spec: POS Panel Category Prefix and Compact Receipt

## 1. Background & Objectives
In the POS view, the right-side panel displays item names but lacks any visual indicator showing which category they belong to. Adding the category name as a prefix will help staff quickly identify product categories.
Additionally, the print receipt needs to be simplified to reduce paper usage and clean up the visual layout. The date and order number currently justify on a single line of 32 characters, leading to truncation/overlaps.

### Objectives:
- Display the category name as a bracketed prefix in the POS order ticket panel: `[Category] Product Name`.
- Reduce printed receipt height by removing store address lines while retaining social media links (`FB Page: veebrew`).
- Resolve date/order number line overlapping by printing them on separate lines.

---

## 2. Proposed Changes

### POS Ticket Category Display
**File:** `lib/widgets/order_ticket.dart`
- Watch `categoriesStreamProvider` from `lib/providers/data_providers.dart` in the `build` method.
- In `ListView.separated`'s `itemBuilder`, look up the category from the list using `item.product.categoryId`.
- Format the product title as `[Category Name] Product Name`.

### Receipt Simplification
**File:** `lib/services/receipt_generator.dart`
- Remove:
  ```dart
  bytes += generator.text("15 Nueva Ecija Street, Barangay Ramon",
      styles: const PosStyles(align: PosAlign.center));
  bytes += generator.text("Magsaysay Bago bantay QC",
      styles: const PosStyles(align: PosAlign.center));
  ```
- Split the date and order number:
  ```dart
  bytes += generator.text("DATE: ${_formatDateTime(DateTime.now())}",
      styles: const PosStyles(align: PosAlign.left));
  bytes += generator.text("ORDER NO: $orderNumber",
      styles: const PosStyles(align: PosAlign.left));
  ```

---

## 3. Verification Plan
- **Manual Visual Review:** Run the POS app and add items to the cart. Check that each item displays its category as a bracketed prefix.
- **Receipt Bytes Verification:** Verify the output sequence in tests or by printing, checking that the address lines are missing and the date/order number are printed on separate lines.
