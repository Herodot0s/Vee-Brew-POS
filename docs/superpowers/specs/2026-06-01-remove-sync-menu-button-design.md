---
name: remove-sync-menu-button
description: Remove Sync Menu button from Admin Page and delete MenuSyncService
metadata:
  type: project
---

# Design Spec: Remove Sync Menu Button

## Purpose
Clean up Admin Dashboard UI by removing the redundant "Sync Menu" button and its associated service.

## Proposed Changes

### 1. UI Modification
**File:** `lib/screens/admin_dashboard_screen.dart`
- Remove `ElevatedButton` for "Sync Menu" (lines 783-807).
- Remove `SizedBox(width: 8)` (line 808).
- Remove `import 'package:vee_brew/services/menu_sync_service.dart';` (or similar).

### 2. Service Deletion
**File:** `lib/services/menu_sync_service.dart`
- Delete file entirely.

## Success Criteria
- Admin Dashboard loads without "Sync Menu" button.
- "WIPE DATABASE" and "Sync All Pending" buttons remain functional.
- Project compiles without errors.
