import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/mock_data.dart';

part 'drift_database.g.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get basePrice => real()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Modifiers extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get name => text()();
  RealColumn get priceDelta => real()();
  TextColumn get groupName => text()();

  @override
  Set<Column> get primaryKey => {id, productId};
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text()();
  RealColumn get totalAmount => real()();
  TextColumn get paymentMethod => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  RealColumn get amountReceived => real().nullable()();
  RealColumn get changeAmount => real().nullable()();
}

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get priceAtTime => real()();
  TextColumn get selectedModifiers => text()();
}

@DriftDatabase(tables: [Categories, Products, Modifiers, Orders, OrderItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(orders, orders.isSynced);
      }
      if (from < 3) {
        // Drop and recreate modifiers table to update primary key and add productId
        await m.deleteTable('modifiers');
        await m.createTable(modifiers);
      }
      if (from < 4) {
        await m.addColumn(orders, orders.amountReceived);
        await m.addColumn(orders, orders.changeAmount);
      }
    },
  );

  Future<void> seedInitialData() async {
    final count = await (select(categories)..limit(1)).get();
    if (count.isNotEmpty) return;

    await transaction(() async {
      // Seed categories
      for (var i = 0; i < mockCategories.length; i++) {
        final cat = mockCategories[i];
        await into(categories).insert(
          CategoriesCompanion.insert(id: cat.id, name: cat.name, sortOrder: i),
        );
      }

      // Seed products
      for (final prod in mockProducts) {
        await into(products).insert(
          ProductsCompanion.insert(
            id: prod.id,
            name: prod.name,
            basePrice: prod.basePrice,
            categoryId: prod.categoryId,
          ),
        );

        // Seed modifiers for this product
        final groups = getModifierGroupsForProduct(prod);
        for (final group in groups) {
          for (final option in group.options) {
            await into(modifiers).insertOnConflictUpdate(
              ModifiersCompanion.insert(
                id: option.id,
                productId: prod.id,
                name: option.name,
                priceDelta: option.priceDelta,
                groupName: group.name,
              ),
            );
          }
        }

        // Add global add-ons for beverage products
        if (prod.categoryId != 'fries' && prod.categoryId != 'hot_brew') {
          for (final addon in mockAddOns) {
            await into(modifiers).insertOnConflictUpdate(
              ModifiersCompanion.insert(
                id: addon.id,
                productId: prod.id,
                name: addon.name,
                priceDelta: addon.priceDelta,
                groupName: 'Add-ons',
              ),
            );
          }
        }
      }
    });
  }

  /// Watches orders within a date range (start inclusive, end inclusive).
  /// Expects Local timezone [DateTime] objects matching UI filters.
  Stream<List<Order>> watchFilteredOrders(DateTime start, DateTime end) {
    return (select(orders)
          ..where((t) => t.createdAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'veebrew.sqlite'));
    return NativeDatabase(file);
  });
}
