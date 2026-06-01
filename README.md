# VeeBrew POS

VeeBrew POS is a Flutter-based Point of Sale system designed for coffee shops and retail outlets. It integrates with Drift local storage for offline-first capabilities and provides a comprehensive Admin Dashboard for inventory and order management.

## Key Features

- **POS Terminal**: Intuitive interface for quick order processing.
- **Admin Dashboard**: Real-time sales monitoring, order history tracking, and inventory management.
- **Offline Sync**: Drift-based database ensures all transactions are logged and synced once connection is restored.
- **Admin Controls**: Manage categories, products, and modifiers.

## Getting Started

1. Ensure Flutter is installed.
2. Run `flutter pub get` to fetch dependencies.
3. Use `dart run build_runner build` to generate necessary Drift database code.
4. Launch on your target platform: `flutter run`.

## Tech Stack

- **Flutter**: UI Framework
- **Riverpod**: State Management
- **Drift**: Local SQLite Database
- **SQLite**: Local data persistence
