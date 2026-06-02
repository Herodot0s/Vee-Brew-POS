---
name: global-addons-db-sync
description: Implement Global Addons and sync database from vee-brew-menu.md
metadata:
  type: project
---

# Design Spec: Global Addons & DB Sync

## Purpose
Directly update the database using the structured menu in `vee-brew-menu.md` and implement "Global Addons" (modifiers available for every beverage cup).

## Proposed Changes

### 1. Data Model Updates (`lib/models/mock_data.dart`)
- Update `mockAddOns` to match `vee-brew-menu.md`:
  - Pearl: 10
  - Nata: 15
  - Coffee Jelly: 15
  - Cream Cheese: 15
  - Crushed Oreo: 15
  - Crushed Graham: 15
  - Classic Foam: 15
  - Egg Pudding: 15
- Ensure beverage categories are correctly identified for addon attachment.

### 2. Database Sync Utility (`lib/services/menu_sync_service.dart`)
- Re-implement a robust parser for `vee-brew-menu.md`.
- **Logic:** 
  1. Wipe existing Categories, Products, and Modifiers.
  2. Parse each section (Milk Tea, Cheesecake, etc.).
  3. Create Products for each flavor with prices defined in size tables.
  4. **Global Addons:** For every product in a beverage category, automatically insert the full list of Addons into the `Modifiers` table.

### 3. UI Trigger
- Ensure the Admin Dashboard can trigger this sync directly.

## Success Criteria
- Running the sync populates the database with exactly the items in `vee-brew-menu.md`.
- Every beverage item in the POS shows the full list of Addons (Pearl, Nata, etc.).
- Fries only show size/flavor modifiers, not beverage addons.
