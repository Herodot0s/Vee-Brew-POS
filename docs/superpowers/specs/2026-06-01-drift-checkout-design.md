# Spec: Drift Database & Checkout Workflow

## Goal
Implement an offline-first data layer using Drift (SQLite) for the VeeBrew POS app, seed it with mock menu data, and implement a modal-based checkout workflow that saves orders to the database.

## 1. Database Architecture & Schema (Drift)
A local SQLite database will be created using the `drift` package.

### Tables
*   **Categories:**
    *   `id` (Text, primary key)
    *   `name` (Text)
    *   `sort_order` (Integer)
*   **Products:**
    *   `id` (Text, primary key)
    *   `name` (Text)
    *   `base_price` (Real)
    *   `category_id` (Text, references Categories)
    *   `image_url` (Text, nullable)
*   **Modifiers:**
    *   `id` (Text, primary key)
    *   `name` (Text)
    *   `price_delta` (Real)
    *   `group_name` (Text) - e.g., "Size", "Sweetness"
*   **Orders:**
    *   `id` (Integer, primary key, auto-increment)
    *   `order_number` (Text) - Daily prefixed sequence, e.g., "20260601-001"
    *   `total_amount` (Real)
    *   `payment_method` (Text) - "Cash" or "Card"
    *   `created_at` (DateTime)
*   **OrderItems:**
    *   `id` (Integer, primary key, auto-increment)
    *   `order_id` (Integer, references Orders)
    *   `product_id` (Text, references Products)
    *   `quantity` (Integer)
    *   `price_at_time` (Real)
    *   `selected_modifiers` (Text) - JSON string representing selected modifiers

### Initialization & Seeding
On application startup, the database will check if the `Categories` table is empty. If empty, an initialization routine will seed the `Categories`, `Products`, and `Modifiers` tables using the static data defined in `lib/models/mock_data.dart`.

## 2. Data Flow & Riverpod Integration
The application will transition from using static mock data to an offline-first reactive model powered by Drift streams.

*   **`databaseProvider`:** Exposes the Drift database instance globally.
*   **`categoriesStreamProvider`:** Watches the `Categories` table. The `CategorySidebar` UI will rebuild automatically when this stream emits new data.
*   **`productsStreamProvider`:** Watches the `Products` table. This stream will be combined with the `selectedCategoryProvider` so the `ProductGrid` reactively displays the correct products for the active category.
*   **`cartProvider`:** Remains an in-memory `StateNotifier` that manages the current uncommitted cart state until the user completes checkout.

## 3. Checkout Modal & Order Saving
The checkout process will be handled via a centered modal overlay.

### Trigger
Tapping the primary action button (e.g., "Charge" or "Pay") in the `OrderTicket` sidebar.

### Modal UI
*   **Container:** Centered dialog, styled with the dark theme surface color (`#1E2329`) and appropriate border radii.
*   **Content:**
    *   Large display of the total amount due, utilizing the tabular font for numerical alignment.
    *   Two distinct, high-contrast payment selection buttons: "Cash" and "Card".
    *   A "Cancel" or "Back" button to dismiss the modal and return to the active order.

### Save Workflow
When a payment method is selected:
1.  **Generate Order Number:** Create a unique order number using the current date and a daily sequence (e.g., `20260601-001`).
2.  **Database Transaction:** Insert a new record into the `Orders` table, followed by inserting all cart items into the `OrderItems` table within a single transaction to ensure data integrity.
3.  **Reset State:** Clear the `cartProvider` to empty the cart.
4.  **Feedback:** Display a brief success indicator (e.g., a green checkmark animation or toast message).
5.  **Dismissal:** Close the modal, leaving the user on a clean, empty POS screen ready for the next order.