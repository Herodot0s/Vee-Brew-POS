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
}

