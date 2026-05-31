# Veebrew POS App Design Specification

## Overview
Veebrew is a milk tea and beverage shop. This specification defines the architecture and UI/UX design for an Android tablet Point of Sale (POS) application built with Flutter. The system prioritizes rapid order entry for high-volume scenarios while gracefully handling complex beverage customizations, and operates reliably in offline-first environments.

## Architecture & Tech Stack
*   **Framework:** Flutter (target: Android tablet landscape).
*   **State Management:** Riverpod (recommended for predictable, scalable state handling of cart, active categories, and modal overlays).
*   **Data Persistence (Offline-First):** `drift` (or `sqflite`). The POS must function 100% autonomously without internet access.
    *   Products, categories, and customization rules are cached locally.
    *   Orders are written to local storage immediately.
*   **Background Sync:** A sync manager monitors network connectivity. When online, local orders are pushed to the backend, and menu updates are pulled down.

## User Interface Layout
The main POS screen utilizes a fixed three-column layout to optimize for tablet ergonomics and cashier speed.

*   **Left Column (20% width):** Vertical Navigation. A scrollable list of high-level categories (e.g., Milk Teas, Fruit Teas, Snacks). Easy to reach with the left thumb while holding the tablet.
*   **Middle Column (55% width):** Product Grid. Displays items belonging to the currently selected category as large, easily tappable cards.
*   **Right Column (25% width):** Order Ticket. A persistent view of the current transaction.
    *   **Header:** Customer name/Order number.
    *   **Body:** Scrollable list of added items, showing selected modifiers beneath each item.
    *   **Footer:** Subtotal, Tax, Total, and a prominent, high-contrast "Pay" button.

## Interaction Patterns: Hybrid Mode
To balance the need for speed with the necessity of milk tea customization, the product grid uses a "Hybrid" interaction model:

1.  **Quick Tap:** Immediately adds the item to the order ticket using its predefined default modifiers (e.g., 100% Sugar, Normal Ice).
2.  **Long Press (or 'Edit' on Ticket):** Opens the Customization Modal for that specific item.

## Customization Modal
When triggered, a modal overlay appears in the center of the screen, dimming the main UI behind it to maintain context without losing focus.

*   **Header:** The name of the selected product (e.g., "Classic Milk Tea").
*   **Body:** Divided into clear groups based on the product's rules:
    *   **Single-Select Groups:** e.g., Sugar Level (0%, 25%, 50%, 75%, 100%), Ice Level (None, Less, Normal, Extra). Displayed as segmented controls or wrapping pill buttons.
    *   **Multi-Select Groups:** e.g., Toppings (Boba, Lychee Jelly). Displayed as toggleable buttons, showing price additions (e.g., "+$0.50").
*   **Footer:** "Add to Order" (or "Update Item" if editing an existing ticket item).

## Data Models (Core Schema)
The application will rely on the following relational structure for the menu:

```dart
class Product {
  final String id;
  final String name;
  final double basePrice;
  final String categoryId;
  // A product belongs to a category and has specific customization rules.
}

class ModifierGroup {
  final String id;
  final String productId; 
  final String name; // e.g., "Sugar Level"
  final bool isRequired; // e.g., Must select a sugar level
  final bool isMultiSelect; // e.g., Can select multiple toppings
}

class ModifierOption {
  final String id;
  final String groupId;
  final String name; // e.g., "50%"
  final double priceDelta; // e.g., +0.50
  final bool isDefault; // Used for Quick Tap behavior
}

class OrderItem {
  final Product product;
  final List<ModifierOption> selectedModifiers;
  // calculatedPrice = product.basePrice + sum(selectedModifiers.priceDelta)
}
```

## Error Handling & Edge Cases
*   **Network Loss:** The UI must display a non-intrusive indicator (e.g., a small cloud icon with a slash in the corner) when offline, but order entry must not be interrupted.
*   **Conflicting Modifiers:** The UI must enforce `isRequired` and `isMultiSelect` rules at the UI level within the Customization Modal to prevent invalid combinations before adding to the ticket.

