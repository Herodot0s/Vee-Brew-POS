# Design Spec - Enhanced Order History & Filtering

**Status:** Draft
**Date:** 2026-06-03
**Topic:** Improving admin order visibility with deep details and time-based filtering.

## 1. Goals
- Show exhaustive order details (items, modifiers, quantities, payment info, timestamps).
- Provide owner-level filtering by Day, Week, Month, Year, and Custom Ranges.
- Maintain existing "Sync" functionality.

## 2. Architecture & Data Flow
### 2.1 State Management (Riverpod)
- `adminOrderFilterProvider`: Notifier tracking selected filter state (Preset vs Custom Range).
- `filteredOrdersStreamProvider`: StreamProvider that watches `adminOrderFilterProvider` and queries the Drift database with date bounds.
- `orderItemDetailProvider`: FutureProvider.family fetching items for a specific order and parsing modifier JSON strings.

### 2.2 UI Components
- **AdminDashboardScreen**: Update layout to `Row` for the Orders tab to accommodate a sidebar.
- **OrderFilterSidebar**: Left-aligned panel with:
    - Preset chips: Today, Yesterday, This Week, This Month, This Year.
    - Custom Range button: Triggers `showDateRangePicker`.
- **EnhancedOrderTile**: 
    - Title: Order # and exact timestamp (HH:mm).
    - Subtitle: Payment Method and Sync Status.
    - Expanded Content: 
        - Table/List of items.
        - Per-item: Name, Quantity, Base Price.
        - Nested: List of selected modifiers with their price deltas.
        - Footer: Summary of Total Amount.

## 3. Database Queries
- Drift `where` clauses using `createdAt.isBetween(start, end)`.
- Use `DateTime` utility functions to calculate start/end of current week/month/year.

## 4. Testing Plan
- **Unit**: Verify date range calculation logic for presets.
- **Widget**: Ensure items and modifiers render correctly inside `ExpansionTile`.
- **Manual**: Verify filtering results match expected counts for mocked database entries.
