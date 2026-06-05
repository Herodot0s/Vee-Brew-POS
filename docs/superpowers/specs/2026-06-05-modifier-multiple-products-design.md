---
name: modifier-multiple-products
description: Allow admins to select and edit multiple products for new or existing modifiers using category-grouped checkboxes
metadata:
  type: design
---

# Design Spec: Modifier Multiple Products Selection

## Purpose
Currently, when creating a new modifier, users can only assign it to a single target product. When editing a shared modifier, users cannot modify which products it applies to. This design spec details the changes needed to support multiple product selections when adding or editing modifiers.

## Proposed Changes

### 1. Database Operations (`lib/screens/admin_dashboard_screen.dart`)
* **Create New Modifier:**
  * When saving a new modifier assigned to $N$ products, we will perform a batch insert.
  * Generate a single unique ID (e.g. `DateTime.now().millisecondsSinceEpoch.toString()`).
  * Insert a row in the `Modifiers` table for each selected `productId` with that same modifier ID, name, price delta, and group name.
* **Edit Existing Modifier:**
  * Retrieve all existing `productId`s currently assigned to `modifier.id` in the database.
  * Compare with the checked `productId`s from the UI to find:
    * **Additions:** Products checked in UI but not in database.
    * **Deletions:** Products unchecked in UI but present in database.
  * Execute a database transaction:
    * Insert new rows for each Addition.
    * Delete rows matching `(id = modifier.id AND productId = deletedProductId)` for each Deletion.
    * Update the `name`, `priceDelta`, and `groupName` for all remaining rows matching `id = modifier.id`.

### 2. User Interface (`lib/screens/admin_dashboard_screen.dart`)
* **Product Selection Widget:**
  * Replace the single-select product dropdown with a scrollable container (e.g., maximum height of `350` pixels).
  * Load all categories and products.
  * Group the products by their categories.
  * Display each category as an `ExpansionTile`.
  * Inside each category tile:
    * Render a "Select All" checkbox in the tile's header/trailing or as the first item. Toggling this checks or unchecks all products within that category.
    * Render a list of `CheckboxListTile` widgets for each product in that category.
* **State Management in Dialog:**
  * Maintain a set/map of checked `productId`s inside `StatefulBuilder`.
  * Initialize this set/map when the dialog opens:
    * If creating a new modifier: start with an empty set.
    * If editing an existing modifier: fetch all current `productId`s matching `modifier.id` and add them to the set.

## Success Criteria
* Users can select multiple products when creating a new modifier.
* Users can edit the product assignment of any existing modifier (adding or removing products).
* Saving updates the database accordingly (adding rows, removing rows, or updating columns).
