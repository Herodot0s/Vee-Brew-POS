# Global Addons & DB Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Synchronize the database with `vee-brew-menu.md` and ensure all beverage products have correct addons.

**Architecture:** Data-driven synchronization using a robust parser service.

**Tech Stack:** Flutter, Drift, Riverpod.

---

### Task 1: Update Mock Addons Data

**Files:**
- Modify: `lib/models/mock_data.dart:156-171`

- [ ] **Step 1: Update `mockAddOns` list**

Modify `lib/models/mock_data.dart` to match the exact prices and names from the menu:
```dart
const List<ModifierOption> mockAddOns = [
  ModifierOption(id: 'add_pearl', groupId: 'addons', name: 'Pearl', priceDelta: 10.0),
  ModifierOption(id: 'add_nata', groupId: 'addons', name: 'Nata', priceDelta: 15.0),
  ModifierOption(id: 'add_coffee_jelly', groupId: 'addons', name: 'Coffee Jelly', priceDelta: 15.0),
  ModifierOption(id: 'add_cream_cheese', groupId: 'addons', name: 'Cream Cheese', priceDelta: 15.0),
  ModifierOption(id: 'add_oreo', groupId: 'addons', name: 'Crushed Oreo', priceDelta: 15.0),
  ModifierOption(id: 'add_graham', groupId: 'addons', name: 'Crushed Graham', priceDelta: 15.0),
  ModifierOption(id: 'add_foam', groupId: 'addons', name: 'Classic Foam', priceDelta: 15.0),
  ModifierOption(id: 'add_pudding', groupId: 'addons', name: 'Egg Pudding', priceDelta: 15.0),
];
```

- [ ] **Step 2: Commit**

```bash
git add lib/models/mock_data.dart
git commit -m "feat(data): update mock addons to match menu"
```

### Task 2: Implement Menu Sync Service

**Files:**
- Create: `lib/services/menu_sync_service.dart`

- [ ] **Step 1: Create the service with a robust parser**

Implement `MenuSyncService` that can:
1. Clear existing menu tables.
2. Parse `vee-brew-menu.md` using regex or markdown parsing.
3. Insert Categories and Products.
4. **Important:** For each beverage product, insert all `mockAddOns` into the `modifiers` table with `groupName: 'Addons'`.

```dart
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import '../models/mock_data.dart';

class MenuSyncService {
  static Future<void> syncMenuFromMarkdown(AppDatabase db, String content) async {
    await db.transaction(() async {
      await db.delete(db.modifiers).go();
      await db.delete(db.products).go();
      await db.delete(db.categories).go();

      // Implement parsing logic here...
      // For each beverage product:
      // for (final addon in mockAddOns) {
      //   await db.into(db.modifiers).insert(ModifiersCompanion.insert(...));
      // }
    });
  }
}
```

- [ ] **Step 2: Verify compilation**

Run: `flutter build bundle`
Expected: Success.

- [ ] **Step 3: Commit**

```bash
git add lib/services/menu_sync_service.dart
git commit -m "feat(services): implement menu sync service"
```

### Task 3: Trigger Sync from Admin Dashboard

**Files:**
- Modify: `lib/screens/admin_dashboard_screen.dart`

- [ ] **Step 1: Add Sync Menu button back with the new logic**

In `_PerformanceStatsBar`'s `Row`:
```dart
ElevatedButton(
  onPressed: () async {
    try {
      final db = ref.read(databaseProvider);
      final file = File('vee-brew-menu.md');
      if (await file.exists()) {
        final content = await file.readAsString();
        await MenuSyncService.syncMenuFromMarkdown(db, content);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu synchronized successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  },
  style: ElevatedButton.styleFrom(backgroundColor: BinanceTheme.primary),
  child: const Text('Sync Menu', style: TextStyle(color: Colors.black)),
),
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/admin_dashboard_screen.dart
git commit -m "feat(admin): re-add Sync Menu button with global addons logic"
```
