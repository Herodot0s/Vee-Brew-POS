import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../providers/data_providers.dart';
import '../providers/category_provider.dart';
import '../theme/binance_theme.dart';

class CategorySidebar extends ConsumerWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Container(
      color: BinanceTheme.canvasDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: BinanceTheme.spaceLg,
              horizontal: BinanceTheme.spaceMd,
            ),
            child: Text(
              'VEEBREW',
              style: BinanceTheme.titleStyle(
                size: 20,
                weight: FontWeight.bold,
                color: BinanceTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat.id;

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(selectedCategoryProvider.notifier)
                          .setCategory(cat.id);
                      ref.read(isAdminModeProvider.notifier).value = false;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(
                        vertical: BinanceTheme.spaceXxs,
                        horizontal: BinanceTheme.spaceXs,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BinanceTheme.surfaceCardDark
                            : Colors.transparent,
                        borderRadius: BinanceTheme.roundedLg,
                        border: isSelected
                            ? Border.all(
                                color: BinanceTheme.surfaceElevatedDark,
                                width: 1,
                              )
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: BinanceTheme.spaceMd,
                          horizontal: BinanceTheme.spaceLg,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(cat.name),
                              color: isSelected
                                  ? BinanceTheme.primary
                                  : BinanceTheme.muted,
                              size: 20,
                            ),
                            const SizedBox(width: BinanceTheme.spaceSm),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: BinanceTheme.titleStyle(
                                  size: 14,
                                  weight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? BinanceTheme.onDark
                                      : BinanceTheme.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(color: BinanceTheme.muted),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(BinanceTheme.spaceMd),
            child: Consumer(
              builder: (context, ref, _) {
                final isAdminMode = ref.watch(isAdminModeProvider);
                return ElevatedButton(
                  onPressed: () {
                    ref.read(isAdminModeProvider.notifier).value = !isAdminMode;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdminMode
                        ? BinanceTheme.primary
                        : BinanceTheme.surfaceElevatedDark,
                    foregroundColor: BinanceTheme.onDark,
                  ),
                  child: Text(isAdminMode ? 'POS Terminal' : 'Admin Area'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

IconData _getCategoryIcon(String categoryName) {
  final name = categoryName.toLowerCase();
  if (name.contains('coffee') || name.contains('espresso') || name.contains('latte') || name.contains('caffeine') || name.contains('cold brew')) {
    return Icons.coffee;
  }
  if (name.contains('tea') || name.contains('matcha') || name.contains('tisane') || name.contains('chai')) {
    return Icons.emoji_food_beverage;
  }
  if (name.contains('beer') || name.contains('brew') || name.contains('draft') || name.contains('alcohol') || name.contains('cider') || name.contains('stout') || name.contains('ipa') || name.contains('ale')) {
    return Icons.sports_bar;
  }
  if (name.contains('pastry') || name.contains('bread') || name.contains('food') || name.contains('snack') || name.contains('cake') || name.contains('dessert') || name.contains('muffin') || name.contains('croissant')) {
    return Icons.restaurant;
  }
  if (name.contains('juice') || name.contains('soda') || name.contains('cold') || name.contains('drink') || name.contains('beverage') || name.contains('water') || name.contains('milkshake')) {
    return Icons.local_drink;
  }
  return Icons.coffee;
}
