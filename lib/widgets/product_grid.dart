import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';
import '../theme/binance_theme.dart';
import '../models/product.dart' as models;
import 'modifier_bottom_sheet.dart';
import 'product_search_bar.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync =
        ref.watch(productsStreamProvider);
    final query = ref.watch(searchQueryProvider);

    return Container(
      color: BinanceTheme.canvasDark,
      padding:
          const EdgeInsets.all(BinanceTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProductSearchBar(),
          const SizedBox(height: BinanceTheme.spaceMd),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty &&
                    query.isNotEmpty) {
                  return _EmptySearchState(
                    query: query,
                    onClear: () => ref
                        .read(searchQueryProvider
                            .notifier)
                        .clear(),
                  );
                }
                return GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    childAspectRatio: 1.25,
                    crossAxisSpacing:
                        BinanceTheme.spaceMd,
                    mainAxisSpacing:
                        BinanceTheme.spaceMd,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Material(
                      color:
                          BinanceTheme.surfaceCardDark,
                      borderRadius:
                          BinanceTheme.roundedLg,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          final modelProduct =
                              models.Product(
                            id: product.id,
                            name: product.name,
                            basePrice:
                                product.basePrice,
                            categoryId:
                                product.categoryId,
                            imageUrl:
                                product.imageUrl,
                          );
                          ModifierBottomSheet.show(
                              context, modelProduct);
                        },
                        splashColor: BinanceTheme
                            .primary
                            .withValues(alpha: 0.1),
                        highlightColor: BinanceTheme
                            .surfaceElevatedDark,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BinanceTheme.roundedLg,
                            border: Border.all(
                              color: BinanceTheme
                                  .surfaceElevatedDark,
                              width: 1,
                            ),
                          ),
                          padding:
                              const EdgeInsets.all(
                                  BinanceTheme
                                      .spaceMd),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .stretch,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: BinanceTheme
                                      .titleStyle(
                                    size: 13,
                                    weight:
                                        FontWeight
                                            .w600,
                                    color:
                                        BinanceTheme
                                            .body,
                                  ),
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                              ),
                              Align(
                                alignment: Alignment
                                    .bottomRight,
                                child: Text(
                                  '₱${product.basePrice.toStringAsFixed(0)}',
                                  style: BinanceTheme
                                      .numberStyle(
                                    size: 14,
                                    weight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                      color: BinanceTheme.muted),
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
  const _EmptySearchState({
    required this.query,
    required this.onClear,
  });

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
            color: BinanceTheme.muted
                .withValues(alpha: 0.5),
          ),
          const SizedBox(
              height: BinanceTheme.spaceMd),
          Text(
            "No products match '$query'",
            style: BinanceTheme.titleStyle(
              size: 14,
              weight: FontWeight.w500,
              color: BinanceTheme.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
              height: BinanceTheme.spaceSm),
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
