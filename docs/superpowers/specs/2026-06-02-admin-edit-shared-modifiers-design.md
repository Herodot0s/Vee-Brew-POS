---
name: admin-edit-shared-modifiers
description: Enable edit and delete actions for shared modifiers in the Admin Dashboard
metadata:
  type: design
---

# Design Spec: Edit and Delete Shared Modifiers

## Purpose
Allow admins to edit and delete shared modifiers (modifiers applied to multiple products, e.g., Sugar Level, Ice Level, global add-ons) directly from the Modifiers tab in the Admin Dashboard. Currently, these action buttons are hidden when a modifier applies to more than one product.

## Proposed Changes

### 1. Admin Dashboard UI (`lib/screens/admin_dashboard_screen.dart`)
- **Always Show Actions:** Modify `_ModifierManagementView` list tiles to render the Edit and Delete icon buttons regardless of `m.productCount`.
- **Pass Metadata:** Pass `isShared: m.productCount > 1` and `productCount: m.productCount` to `_showModifierDialog` and `_showDeleteModifierConfirmation`.

### 2. Edit Modifier Dialog (`_showModifierDialog`)
- **UI adaptation:** If `isShared` is true:
  - Do not render the "Target Product" dropdown selector.
  - Render a read-only message: "Applied to $productCount products" or similar descriptive text.
- **Database Update:** 
  - If updating a shared modifier, update all modifier entries matching the modifier `id`:
    ```dart
    await (db.update(db.modifiers)..where((t) => t.id.equals(modifier.id)))
        .write(
          ModifiersCompanion(
            name: Value(nameController.text),
            priceDelta: Value(price),
            groupName: Value(groupController.text),
          ),
        );
    ```

### 3. Delete Modifier Dialog (`_showDeleteModifierConfirmation`)
- **UI warning:** If `isShared` is true, show warning text: "Delete ${modifier.name} from $productCount products?".
- **Database Delete:**
  - If deleting a shared modifier, delete all modifier entries matching the modifier `id`:
    ```dart
    await (db.delete(db.modifiers)..where((t) => t.id.equals(modifier.id))).go();
    ```

## Success Criteria
- Modifiers list in Admin tab shows Edit and Delete buttons on all entries (even size, ice, sugar levels).
- Editing a shared modifier updates all products' instances of that modifier (same ID).
- Deleting a shared modifier removes it from all products.
