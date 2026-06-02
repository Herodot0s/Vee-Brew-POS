import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/database/drift_database.dart';
import 'package:veebrew/providers/admin_provider.dart';
import 'package:veebrew/providers/database_provider.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.memory();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('admin modifiers collapse exact duplicates across products', () async {
    await db
        .into(db.categories)
        .insert(
          const CategoriesCompanion(
            id: Value('milk_tea'),
            name: Value('Milk Tea'),
            sortOrder: Value(0),
          ),
        );
    await db
        .into(db.products)
        .insert(
          const ProductsCompanion(
            id: Value('p1'),
            name: Value('Product 1'),
            basePrice: Value(10),
            categoryId: Value('milk_tea'),
          ),
        );
    await db
        .into(db.products)
        .insert(
          const ProductsCompanion(
            id: Value('p2'),
            name: Value('Product 2'),
            basePrice: Value(12),
            categoryId: Value('milk_tea'),
          ),
        );

    await db
        .into(db.modifiers)
        .insert(
          const ModifiersCompanion(
            id: Value('add_pearl'),
            productId: Value('p1'),
            name: Value('Pearl'),
            priceDelta: Value(10),
            groupName: Value('Add-ons'),
          ),
        );
    await db
        .into(db.modifiers)
        .insert(
          const ModifiersCompanion(
            id: Value('add_pearl'),
            productId: Value('p2'),
            name: Value('Pearl'),
            priceDelta: Value(10),
            groupName: Value('Add-ons'),
          ),
        );
    await db
        .into(db.modifiers)
        .insert(
          const ModifiersCompanion(
            id: Value('add_nata'),
            productId: Value('p2'),
            name: Value('Nata'),
            priceDelta: Value(15),
            groupName: Value('Add-ons'),
          ),
        );

    final completer = Completer<List<ModifierWithProduct>>();
    final subscription = container.listen(adminFilteredModifiersProvider, (
      _,
      next,
    ) {
      next.whenData((modifiers) {
        if (!completer.isCompleted) {
          completer.complete(modifiers);
        }
      });
    }, fireImmediately: true);
    addTearDown(subscription.close);

    final modifiers = await completer.future;

    expect(modifiers.map((m) => m.modifier.name), ['Nata', 'Pearl']);
  });
}
