# Admin Edit Shared Modifiers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable editing and deleting shared modifiers (modifiers belonging to multiple products) in the Admin Dashboard.

**Architecture:** Update `_ModifierManagementView` list tiles in `lib/screens/admin_dashboard_screen.dart` to always show Edit/Delete buttons. Update dialogs and database calls to update/delete by ID across all products when the modifier is shared.

**Tech Stack:** Flutter, Drift Database, Riverpod

---

### Task 1: Update Tests to Check Shared Modifier Edit/Delete

**Files:**
- Modify: `test/admin_test.dart`

- [ ] **Step 1: Write failing tests for shared modifier edit and delete**

Replace/Add test cases in `test/admin_test.dart` to verify that updating or deleting a shared modifier updates/deletes all instances with that ID.

```dart
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
```

- [ ] **Step 2: Run tests to verify they pass**

(These unit tests don't touch the UI directly, so they should pass immediately because they test standard Drift operations, but they verify the database behavior we will rely on.)

Run: `flutter test test/admin_test.dart`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add test/admin_test.dart
git commit -m "test: add shared modifier update and delete db behavior tests"
```

---

### Task 2: Implement Shared Modifier Edit UI and Dialogs

**Files:**
- Modify: `lib/screens/admin_dashboard_screen.dart`

- [ ] **Step 1: Update the modifiers list view row**

In `lib/screens/admin_dashboard_screen.dart`, modify `_ModifierManagementView` to always show Edit and Delete actions, passing `isShared: m.productCount > 1` and `productCount: m.productCount`.

```dart
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: BinanceTheme.primary,
                          ),
                          onPressed: () => _showModifierDialog(
                            context,
                            ref,
                            modifier: m.modifier,
                            isShared: m.productCount > 1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              _showDeleteModifierConfirmation(
                                context,
                                ref,
                                m.modifier,
                                isShared: m.productCount > 1,
                                productCount: m.productCount,
                              ),
                        ),
                      ],
                    ),
```

- [ ] **Step 2: Update `_showModifierDialog` parameters and body**

Modify signature and contents of `_showModifierDialog`:
- Add `bool isShared = false` parameter.
- Add `isShared` handling to title, dropdown, and save button.

```dart
  void _showModifierDialog(
    BuildContext context,
    WidgetRef ref, {
    Modifier? modifier,
    bool isShared = false,
  }) {
    final nameController = TextEditingController(text: modifier?.name);
    final priceController = TextEditingController(
      text: modifier?.priceDelta.toString(),
    );
    final groupController = TextEditingController(text: modifier?.groupName);
    String? selectedProductId = modifier?.productId;

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final productsAsync = ref.watch(allProductsStreamProvider);
          return productsAsync.when(
            data: (products) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                backgroundColor: BinanceTheme.surfaceCardDark,
                title: Text(
                  modifier == null
                      ? 'Add Modifier'
                      : (isShared ? 'Edit Shared Modifier' : 'Edit Modifier'),
                  style: const TextStyle(color: BinanceTheme.onDark),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: BinanceTheme.onDark),
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: BinanceTheme.muted),
                        ),
                      ),
                      TextField(
                        controller: priceController,
                        style: const TextStyle(color: BinanceTheme.onDark),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Price Delta',
                          labelStyle: TextStyle(color: BinanceTheme.muted),
                        ),
                      ),
                      TextField(
                        controller: groupController,
                        style: const TextStyle(color: BinanceTheme.onDark),
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                          hintText: 'e.g., Size, Syrup',
                          hintStyle: TextStyle(color: BinanceTheme.muted),
                          labelStyle: TextStyle(color: BinanceTheme.muted),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isShared)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Applied to multiple products',
                            style: TextStyle(
                              color: BinanceTheme.muted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          dropdownColor: BinanceTheme.surfaceCardDark,
                          value: selectedProductId,
                          style: const TextStyle(color: BinanceTheme.onDark),
                          decoration: const InputDecoration(
                            labelText: 'Target Product',
                            labelStyle: TextStyle(color: BinanceTheme.muted),
                          ),
                          items: products
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedProductId = val),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          groupController.text.isEmpty ||
                          (!isShared && selectedProductId == null))
                        return;
                      final db = ref.read(databaseProvider);
                      final price =
                          double.tryParse(priceController.text) ?? 0.0;

                      if (modifier == null) {
                        await db
                            .into(db.modifiers)
                            .insert(
                              ModifiersCompanion.insert(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                productId: selectedProductId!,
                                name: nameController.text,
                                priceDelta: price,
                                groupName: groupController.text,
                              ),
                            );
                      } else {
                        if (isShared) {
                          await (db.update(db.modifiers)
                                ..where((t) => t.id.equals(modifier.id)))
                              .write(
                                ModifiersCompanion(
                                  name: Value(nameController.text),
                                  priceDelta: Value(price),
                                  groupName: Value(groupController.text),
                                ),
                              );
                        } else {
                          await (db.update(db.modifiers)
                                ..where(
                                  (t) =>
                                      t.id.equals(modifier.id) &
                                      t.productId.equals(modifier.productId),
                                ))
                              .write(
                                ModifiersCompanion(
                                  productId: Value(selectedProductId!),
                                  name: Value(nameController.text),
                                  priceDelta: Value(price),
                                  groupName: Value(groupController.text),
                                ),
                              );
                        }
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            error: (_, __) =>
                const AlertDialog(content: Text('Error loading products')),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
```

- [ ] **Step 3: Update `_showDeleteModifierConfirmation` signature and body**

Modify signature and contents of `_showDeleteModifierConfirmation`:
- Add `bool isShared = false` and `int productCount = 1` parameters.
- Check `isShared` to warn user and do DB deletion.

```dart
  void _showDeleteModifierConfirmation(
    BuildContext context,
    WidgetRef ref,
    Modifier modifier, {
    bool isShared = false,
    int productCount = 1,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BinanceTheme.surfaceCardDark,
        title: const Text(
          'Delete Modifier',
          style: TextStyle(color: BinanceTheme.onDark),
        ),
        content: Text(
          isShared
              ? 'Delete ${modifier.name} from $productCount products?'
              : 'Delete ${modifier.name}?',
          style: const TextStyle(color: BinanceTheme.onDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              if (isShared) {
                await (db.delete(db.modifiers)
                      ..where((t) => t.id.equals(modifier.id)))
                    .go();
              } else {
                await (db.delete(db.modifiers)
                      ..where(
                        (t) =>
                            t.id.equals(modifier.id) &
                            t.productId.equals(modifier.productId),
                      ))
                    .go();
              }
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 4: Run flutter test to verify all passes**

Run: `flutter test`
Expected: ALL PASS

- [ ] **Step 5: Commit changes**

```bash
git add lib/screens/admin_dashboard_screen.dart
git commit -m "feat: show edit/delete on shared modifiers and update/delete them across products"
```
