import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:veebrew/database/drift_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  test('Database migration and sync flag', () async {
    // Add dummy order
    final id = await db
        .into(db.orders)
        .insert(
          OrdersCompanion.insert(
            orderNumber: '20260601-001',
            totalAmount: 10.0,
            paymentMethod: 'Cash',
            createdAt: DateTime.now(),
            isSynced: const Value(false),
          ),
        );

    var order = await (db.select(
      db.orders,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(order.isSynced, isFalse);

    await (db.update(db.orders)..where((t) => t.id.equals(id))).write(
      const OrdersCompanion(isSynced: Value(true)),
    );

    order = await (db.select(
      db.orders,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(order.isSynced, isTrue);
  });

  test('Database customer name persistence', () async {
    final id = await db.into(db.orders).insert(
      OrdersCompanion.insert(
        orderNumber: '20260605-999',
        totalAmount: 150.0,
        paymentMethod: 'Cash',
        createdAt: DateTime.now(),
        customerName: const Value('Juan Dela Cruz'),
      ),
    );

    final order = await (db.select(db.orders)..where((t) => t.id.equals(id))).getSingle();
    expect(order.customerName, 'Juan Dela Cruz');
  });

  test('Modifier update and delete only affects specific product', () async {
    // Seed category
    await db.into(db.categories).insert(
      const CategoriesCompanion(
        id: Value('milk_tea'),
        name: Value('Milk Tea'),
        sortOrder: Value(0),
      ),
    );

    // Seed two products
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p1'),
        name: Value('Product 1'),
        basePrice: Value(10.0),
        categoryId: Value('milk_tea'),
      ),
    );
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p2'),
        name: Value('Product 2'),
        basePrice: Value(12.0),
        categoryId: Value('milk_tea'),
      ),
    );

    // Seed modifier for both products
    await db.into(db.modifiers).insert(
      const ModifiersCompanion(
        id: Value('add_pearl'),
        productId: Value('p1'),
        name: Value('Pearl'),
        priceDelta: Value(10.0),
        groupName: Value('Addons'),
      ),
    );
    await db.into(db.modifiers).insert(
      const ModifiersCompanion(
        id: Value('add_pearl'),
        productId: Value('p2'),
        name: Value('Pearl'),
        priceDelta: Value(10.0),
        groupName: Value('Addons'),
      ),
    );

    // Update modifier for p1
    await (db.update(db.modifiers)
          ..where((t) => t.id.equals('add_pearl') & t.productId.equals('p1')))
        .write(const ModifiersCompanion(priceDelta: Value(15.0)));

    // Verify p1 modifier is updated, p2 modifier is unchanged
    final p1Mod = await (db.select(db.modifiers)
          ..where((t) => t.id.equals('add_pearl') & t.productId.equals('p1')))
        .getSingle();
    expect(p1Mod.priceDelta, 15.0);

    final p2Mod = await (db.select(db.modifiers)
          ..where((t) => t.id.equals('add_pearl') & t.productId.equals('p2')))
        .getSingle();
    expect(p2Mod.priceDelta, 10.0);

    // Delete modifier for p1
    await (db.delete(db.modifiers)
          ..where((t) => t.id.equals('add_pearl') & t.productId.equals('p1')))
        .go();

    // Verify p1 modifier is deleted, p2 modifier remains
    final p1Mods = await (db.select(db.modifiers)
          ..where((t) => t.id.equals('add_pearl') & t.productId.equals('p1')))
        .get();
    expect(p1Mods.isEmpty, isTrue);

    final p2Mods = await (db.select(db.modifiers)
          ..where((t) => t.id.equals('add_pearl') & t.productId.equals('p2')))
        .get();
    expect(p2Mods.length, 1);
  });

  test('Shared modifier update affects all products', () async {
    // Seed category
    await db.into(db.categories).insert(
      const CategoriesCompanion(
        id: Value('milk_tea'),
        name: Value('Milk Tea'),
        sortOrder: Value(0),
      ),
    );

    // Seed two products
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p1'),
        name: Value('Product 1'),
        basePrice: Value(10.0),
        categoryId: Value('milk_tea'),
      ),
    );
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p2'),
        name: Value('Product 2'),
        basePrice: Value(12.0),
        categoryId: Value('milk_tea'),
      ),
    );

    // Seed shared modifier for both products
    await db.into(db.modifiers).insert(
      const ModifiersCompanion(
        id: Value('add_pearl'),
        productId: Value('p1'),
        name: Value('Pearl'),
        priceDelta: Value(10.0),
        groupName: Value('Addons'),
      ),
    );
    await db.into(db.modifiers).insert(
      const ModifiersCompanion(
        id: Value('add_pearl'),
        productId: Value('p2'),
        name: Value('Pearl'),
        priceDelta: Value(10.0),
        groupName: Value('Addons'),
      ),
    );

    // Update shared modifier globally using only ID
    await (db.update(db.modifiers)..where((t) => t.id.equals('add_pearl'))).write(
      const ModifiersCompanion(
        name: Value('Super Pearl'),
        priceDelta: Value(15.0),
        groupName: Value('Premium Addons'),
      ),
    );

    // Verify all instances updated
    final mods = await (db.select(db.modifiers)..where((t) => t.id.equals('add_pearl'))).get();
    expect(mods.length, 2);
    for (final m in mods) {
      expect(m.name, 'Super Pearl');
      expect(m.priceDelta, 15.0);
      expect(m.groupName, 'Premium Addons');
    }
  });

  test('Shared modifier delete affects all products', () async {
    // Seed category
    await db.into(db.categories).insert(
      const CategoriesCompanion(
        id: Value('milk_tea'),
        name: Value('Milk Tea'),
        sortOrder: Value(0),
      ),
    );

    // Seed two products
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p1'),
        name: Value('Product 1'),
        basePrice: Value(10.0),
        categoryId: Value('milk_tea'),
      ),
    );
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p2'),
        name: Value('Product 2'),
        basePrice: Value(12.0),
        categoryId: Value('milk_tea'),
      ),
    );

    // Seed shared modifier for both products
    await db.into(db.modifiers).insert(
      const ModifiersCompanion(
        id: Value('add_pearl'),
        productId: Value('p1'),
        name: Value('Pearl'),
        priceDelta: Value(10.0),
        groupName: Value('Addons'),
      ),
    );
    await db.into(db.modifiers).insert(
      const ModifiersCompanion(
        id: Value('add_pearl'),
        productId: Value('p2'),
        name: Value('Pearl'),
        priceDelta: Value(10.0),
        groupName: Value('Addons'),
      ),
    );

    // Delete shared modifier globally using only ID
    await (db.delete(db.modifiers)..where((t) => t.id.equals('add_pearl'))).go();

    // Verify all instances deleted
    final mods = await (db.select(db.modifiers)..where((t) => t.id.equals('add_pearl'))).get();
    expect(mods.isEmpty, isTrue);
  });

  test('Bulk insert modifier for multiple products', () async {
    // Seed category
    await db.into(db.categories).insert(
      const CategoriesCompanion(
        id: Value('beverage'),
        name: Value('Beverage'),
        sortOrder: Value(0),
      ),
    );

    // Seed two products
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p1'),
        name: Value('Product 1'),
        basePrice: Value(10.0),
        categoryId: Value('beverage'),
      ),
    );
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p2'),
        name: Value('Product 2'),
        basePrice: Value(12.0),
        categoryId: Value('beverage'),
      ),
    );

    // Perform bulk insert simulation
    final newId = 'test_bulk_mod';
    final selectedProductIds = {'p1', 'p2'};
    await db.transaction(() async {
      for (final prodId in selectedProductIds) {
        await db.into(db.modifiers).insert(
          ModifiersCompanion.insert(
            id: newId,
            productId: prodId,
            name: 'Extra Shot',
            priceDelta: 1.5,
            groupName: 'Addons',
          ),
        );
      }
    });

    // Assert rows created
    final mods = await (db.select(db.modifiers)..where((t) => t.id.equals(newId))).get();
    expect(mods.length, 2);
    expect(mods.any((m) => m.productId == 'p1'), isTrue);
    expect(mods.any((m) => m.productId == 'p2'), isTrue);
  });

  test('Edit existing modifier assignments (additions, deletions, and field updates)', () async {
    // Seed category
    await db.into(db.categories).insert(
      const CategoriesCompanion(
        id: Value('beverage'),
        name: Value('Beverage'),
        sortOrder: Value(0),
      ),
    );

    // Seed products
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p1'),
        name: Value('Product 1'),
        basePrice: Value(10.0),
        categoryId: Value('beverage'),
      ),
    );
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p2'),
        name: Value('Product 2'),
        basePrice: Value(12.0),
        categoryId: Value('beverage'),
      ),
    );
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p3'),
        name: Value('Product 3'),
        basePrice: Value(15.0),
        categoryId: Value('beverage'),
      ),
    );

    // Initially assign modifier to p1 and p2
    final modId = 'test_edit_mod';
    await db.into(db.modifiers).insert(ModifiersCompanion.insert(id: modId, productId: 'p1', name: 'Original', priceDelta: 1.0, groupName: 'Grp'));
    await db.into(db.modifiers).insert(ModifiersCompanion.insert(id: modId, productId: 'p2', name: 'Original', priceDelta: 1.0, groupName: 'Grp'));

    // Simulation of editing assignments to p2 and p3 (p1 is removed, p3 is added, fields updated)
    final selectedProductIds = {'p2', 'p3'};
    final name = 'Updated';
    final price = 2.0;
    final group = 'New Grp';

    await db.transaction(() async {
      final existing = await (db.select(db.modifiers)..where((t) => t.id.equals(modId))).get();
      final existingProdIds = existing.map((m) => m.productId).toSet();

      // Additions
      final toAdd = selectedProductIds.difference(existingProdIds);
      for (final prodId in toAdd) {
        await db.into(db.modifiers).insert(
          ModifiersCompanion.insert(
            id: modId,
            productId: prodId,
            name: name,
            priceDelta: price,
            groupName: group,
          ),
        );
      }

      // Deletions
      final toDelete = existingProdIds.difference(selectedProductIds);
      if (toDelete.isNotEmpty) {
        await (db.delete(db.modifiers)
              ..where((t) => t.id.equals(modId) & t.productId.isIn(toDelete)))
            .go();
      }

      // Updates
      final remaining = selectedProductIds.intersection(existingProdIds);
      if (remaining.isNotEmpty) {
        await (db.update(db.modifiers)
              ..where((t) => t.id.equals(modId) & t.productId.isIn(remaining)))
            .write(
              ModifiersCompanion(
                name: Value(name),
                priceDelta: Value(price),
                groupName: Value(group),
              ),
            );
      }
    });

    // Assert final database state
    final finalMods = await (db.select(db.modifiers)..where((t) => t.id.equals(modId))).get();
    expect(finalMods.length, 2);
    expect(finalMods.any((m) => m.productId == 'p1'), isFalse); // Deleted
    expect(finalMods.any((m) => m.productId == 'p2'), isTrue);  // Maintained & Updated
    expect(finalMods.any((m) => m.productId == 'p3'), isTrue);  // Added

    for (final m in finalMods) {
      expect(m.name, 'Updated');
      expect(m.priceDelta, 2.0);
      expect(m.groupName, 'New Grp');
    }
  });
}


