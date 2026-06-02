import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';
import '../providers/cart_provider.dart';
import '../theme/binance_theme.dart';
import '../models/product.dart' as models;
import 'modifier_bottom_sheet.dart';
import 'product_search_bar.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final query = ref.watch(searchQueryProvider);

    return Container(
      color: BinanceTheme.canvasDark,
      padding: const EdgeInsets.all(BinanceTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProductSearchBar(),
          const SizedBox(height: BinanceTheme.spaceMd),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty && query.isNotEmpty) {
                  return _EmptySearchState(
                    query: query,
                    onClear: () =>
                        ref.read(searchQueryProvider.notifier).clear(),
                  );
                }
                final cart = ref.watch(cartProvider);

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    childAspectRatio: 1.08,
                    crossAxisSpacing: BinanceTheme.spaceMd,
                    mainAxisSpacing: BinanceTheme.spaceMd,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final cartQuantity = cart.where((item) => item.product.id == product.id).length;
                    final isSelected = cartQuantity > 0;

                    return Material(
                      color: isSelected
                          ? BinanceTheme.surfaceElevatedDark
                          : BinanceTheme.surfaceCardDark,
                      borderRadius: BinanceTheme.roundedLg,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final modelProduct = models.Product(
                            id: product.id,
                            name: product.name,
                            basePrice: product.basePrice,
                            categoryId: product.categoryId,
                            imageUrl: product.imageUrl,
                          );
                          ref.read(cartProvider.notifier).addQuickTap(modelProduct);
                        },
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          final modelProduct = models.Product(
                            id: product.id,
                            name: product.name,
                            basePrice: product.basePrice,
                            categoryId: product.categoryId,
                            imageUrl: product.imageUrl,
                          );
                          ModifierBottomSheet.show(context, modelProduct);
                        },
                        splashColor: BinanceTheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        highlightColor: BinanceTheme.surfaceElevatedDark,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BinanceTheme.roundedLg,
                                border: Border.all(
                                  color: isSelected
                                      ? BinanceTheme.primary
                                      : BinanceTheme.surfaceElevatedDark,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: BinanceTheme.spaceXs,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  categoriesAsync.maybeWhen(
                                    data: (cats) {
                                      try {
                                        final cat = cats.firstWhere((c) => c.id == product.categoryId);
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(cat.name).withValues(alpha: 0.12),
                                                borderRadius: BinanceTheme.roundedSm,
                                                border: Border.all(
                                                  color: _getCategoryColor(cat.name).withValues(alpha: 0.24),
                                                  width: 0.5,
                                                ),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _getCategoryIcon(cat.name),
                                                    size: 10,
                                                    color: _getCategoryColor(cat.name),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      cat.name.toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 8.0,
                                                        fontWeight: FontWeight.w800,
                                                        color: _getCategoryColor(cat.name),
                                                        letterSpacing: 0.5,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } catch (_) {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                    orElse: () => const SizedBox.shrink(),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        product.name,
                                        style: BinanceTheme.titleStyle(
                                          size: 13,
                                          weight: FontWeight.w600,
                                          color: BinanceTheme.body,
                                        ).copyWith(height: 1.2),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₱${product.basePrice.toStringAsFixed(0)}',
                                        style: BinanceTheme.numberStyle(
                                          size: 14,
                                          weight: FontWeight.w600,
                                          color: isSelected
                                              ? BinanceTheme.primary
                                              : BinanceTheme.body,
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.mediumImpact();
                                            final modelProduct = models.Product(
                                              id: product.id,
                                              name: product.name,
                                              basePrice: product.basePrice,
                                              categoryId: product.categoryId,
                                              imageUrl: product.imageUrl,
                                            );
                                            ModifierBottomSheet.show(context, modelProduct);
                                          },
                                          borderRadius: BorderRadius.circular(14),
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? BinanceTheme.primary.withValues(alpha: 0.15)
                                                  : BinanceTheme.surfaceElevatedDark,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.tune,
                                              size: 14,
                                              color: isSelected
                                                  ? BinanceTheme.primary
                                                  : BinanceTheme.muted,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (cartQuantity > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: BinanceTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  width: 18,
                                  height: 18,
                                  child: Center(
                                    child: Text(
                                      '$cartQuantity',
                                      style: BinanceTheme.numberStyle(
                                        size: 10,
                                        weight: FontWeight.bold,
                                        color: BinanceTheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(color: BinanceTheme.muted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: BinanceTheme.muted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: BinanceTheme.spaceMd),
          Text(
            "No products match '$query'",
            style: BinanceTheme.titleStyle(
              size: 14,
              weight: FontWeight.w500,
              color: BinanceTheme.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: BinanceTheme.spaceSm),
          GestureDetector(
            onTap: onClear,
            child: Text(
              'Clear Search',
              style: BinanceTheme.titleStyle(
                size: 13,
                weight: FontWeight.w600,
                color: BinanceTheme.primary,
              ),
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

Color _getCategoryColor(String categoryName) {
  final name = categoryName.toLowerCase();
  if (name.contains('coffee') || name.contains('espresso') || name.contains('latte') || name.contains('caffeine') || name.contains('cold brew')) {
    return const Color(0xFFF0B90B); // Binance Gold / Amber
  }
  if (name.contains('tea') || name.contains('matcha') || name.contains('tisane') || name.contains('chai')) {
    return const Color(0xFF0ECB81); // Binance Trading Up Green
  }
  if (name.contains('beer') || name.contains('brew') || name.contains('draft') || name.contains('alcohol') || name.contains('cider')) {
    return const Color(0xFFF85F73); // Red Accent
  }
  if (name.contains('pastry') || name.contains('bread') || name.contains('food') || name.contains('snack') || name.contains('cake') || name.contains('dessert')) {
    return const Color(0xFFFF6B81); // Soft Pink/Rose
  }
  if (name.contains('juice') || name.contains('soda') || name.contains('cold') || name.contains('drink') || name.contains('beverage')) {
    return const Color(0xFF3861FB); // CoinMarketCap Blue
  }
  return BinanceTheme.muted;
}
