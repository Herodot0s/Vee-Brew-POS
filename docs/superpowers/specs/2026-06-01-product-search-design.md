# Spec: Product Search & Filtering in Product Grid

## Goal
Implement a local product search and filtering input at the top of the Product Grid, enabling cashiers to quickly find specific beverage items or snacks in high-volume scenarios.

## 1. UI/UX Design (Binance Theme)
*   **Location:** Anchored at the top of the `ProductGrid` widget, spanning full width of the grid column.
*   **Styling:**
    *   Container background: `#1e2329` (`BinanceTheme.surfaceCardDark`).
    *   Text color: `#eaecef` (`BinanceTheme.body`).
    *   Border radius: 8px (`BinanceTheme.roundedLg`).
    *   Height: 40px.
    *   Focus state: 1px yellow outline (`BinanceTheme.primary`).
*   **Elements:**
    *   Left/Prefix Icon: Magnifying glass (`Icons.search`) in muted color (`#707a8a`).
    *   Input: Hint text "Search products..." in muted color.
    *   Right/Suffix Icon: Close/Clear button (`Icons.clear`) that appears only when the user has entered text, clearing the input on tap.

## 2. State Management & Riverpod Integration
A new state provider will track the search query.

*   **`searchQueryProvider`:** A `StateProvider<String>` initialized to an empty string `""`.
*   **`productsStreamProvider`:** Watches both `selectedCategoryProvider` and `searchQueryProvider`.
    *   When the query is empty, query all products matching the `selectedCategory`.
    *   When the query is not empty, modify the database select query to add a search condition:
        ```dart
        db.select(db.products)
          ..where((t) => t.categoryId.equals(selectedCategory) & t.name.contains(searchQuery))
        ```

## 3. Empty State Handling
If the filtered products list is empty:
*   Display a centered screen message: "No products match '<query>'".
*   Provide a "Clear Search" text link or button to reset the search input.

## 4. Test Coverage
*   **Unit Tests:** Verify `productsStreamProvider` outputs correctly with search queries.
*   **Widget Tests:** Verify search input updates query state, clears correctly, and filters the grid items.
