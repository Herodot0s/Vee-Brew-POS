# Design Spec: Low-Specs Performance Optimization for Android 5.1

## Overview
Optimize the application to resolve startup delay, general UI lag, and input delays when running offline on low-specification Android 5.1 (Lollipop / API 22) hardware. The target device operates fully offline, which triggers network timeouts when loading web fonts, and possesses a low-end GPU/CPU that experiences bottlenecks with complex rendering operations.

## Proposed Changes

### 1. Font Loading & Offline Optimization
- **File:** `lib/main.dart`
- **Change:** Import the `google_fonts` package and configure it to disable runtime HTTP fetching on startup.
- **Reasoning:** In offline mode, the `google_fonts` package tries to download font binaries from Google Fonts servers. Since there is no internet, the connection hangs and waits for network timeout on the UI thread, causing severe startup delay and sluggish transitions. Disabling runtime fetching forces instant local fallback.

### 2. Repaint Boundary Isolation
- **File:** `lib/screens/pos_screen.dart`
- **Change:** Wrap key layout components (`CategorySidebar`, `ProductGrid`, `OrderTicket`, and `AdminDashboardScreen`) inside `RepaintBoundary` widgets.
- **Reasoning:** Separating these distinct sections prevents visual changes in one section (e.g., adding an item to the cart, hover states, or search filtering) from forcing the GPU to repaint the entire screen layout.

### 3. GPU Clipping Optimizations
- **Files:** `lib/widgets/product_grid.dart`, `lib/widgets/admin/bento_card.dart`
- **Change:** Change `clipBehavior: Clip.antiAlias` to `clipBehavior: Clip.none` or `Clip.hardEdge` inside card-based and list-based Material/Card elements.
- **Reasoning:** Anti-aliased clipping is a multi-pass GPU operation. Low-spec mobile GPUs (such as those on Android 5.1 chipsets) undergo performance drops under anti-aliasing. Replacing it with hard-edge/no-clip improves frame rates during scrolling.

### 4. Code Lookup Computation Optimizations
- **File:** `lib/widgets/order_ticket.dart`
- **Change:** Replace the O(N) linear search for categories in the list builder with a pre-computed O(1) lookup Map.
- **Reasoning:** Minimizes CPU cycles consumed by list builds when cart contents change.

## Verification & Testing Plan
1. **Compilation Check**: Verify that the application compiles without errors on all target platforms.
2. **Offline Mode Simulation**: Verify that the application starts up instantly and does not hang when running on local devices without internet access.
3. **Smoke Test**: Ensure all key functions (product search, category selection, adding to cart, checkout, printing) work correctly with optimizations in place.
