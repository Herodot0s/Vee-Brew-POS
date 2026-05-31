import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import '../providers/database_provider.dart';
import '../providers/category_provider.dart';

final categoriesStreamProvider =
    StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.categories)
        ..orderBy([
          (t) => OrderingTerm(expression: t.sortOrder),
        ]))
      .watch();
});

final productsStreamProvider =
    StreamProvider<List<Product>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedCategory =
      ref.watch(selectedCategoryProvider);
  return (db.select(db.products)
        ..where(
            (t) => t.categoryId.equals(selectedCategory)))
      .watch();
});
