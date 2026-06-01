import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import '../providers/database_provider.dart';
import '../providers/category_provider.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.categories,
  )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  () => SearchQueryNotifier(),
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  return (db.select(db.products)..where((t) {
        if (query.isNotEmpty) {
          return t.name.like('%$query%');
        }
        return t.categoryId.equals(selectedCategory);
      }))
      .watch();
});

final modifiersStreamProvider = StreamProvider<List<Modifier>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.modifiers)).watch();
});

enum TimeRange { day, week, month, year }
