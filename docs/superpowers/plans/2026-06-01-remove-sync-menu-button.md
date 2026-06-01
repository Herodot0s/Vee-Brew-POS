# Remove Sync Menu Button Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove "Sync Menu" button from Admin Dashboard and delete `MenuSyncService`.

**Architecture:** UI cleanup and service removal.

**Tech Stack:** Flutter, Riverpod, Drift.

---

### Task 1: Remove Sync Menu Button from UI

**Files:**
- Modify: `lib/screens/admin_dashboard_screen.dart:11` (Remove import)
- Modify: `lib/screens/admin_dashboard_screen.dart:783-808` (Remove button and spacing)

- [ ] **Step 1: Remove the import and the button code**

Modify `lib/screens/admin_dashboard_screen.dart`:
- Remove `import '../services/menu_sync_service.dart';`
- Remove the `ElevatedButton` block for "Sync Menu" and the following `SizedBox`.

- [ ] **Step 2: Verify UI compiles**

Run: `flutter build bundle` (or just check for static analysis errors)
Expected: Success.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/admin_dashboard_screen.dart
git commit -m "refactor(admin): remove Sync Menu button and import"
```

### Task 2: Delete MenuSyncService

**Files:**
- Modify: `lib/services/menu_sync_service.dart` (Delete)

- [ ] **Step 1: Delete the file**

Run: `rm lib/services/menu_sync_service.dart`

- [ ] **Step 2: Verify project compiles**

Run: `flutter build bundle`
Expected: Success.

- [ ] **Step 3: Commit**

```bash
git add lib/services/menu_sync_service.dart
git commit -m "feat(services): delete MenuSyncService"
```
