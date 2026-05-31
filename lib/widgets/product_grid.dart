import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';
import '../theme/binance_theme.dart';
import '../models/product.dart' as models;
import 'modifier_bottom_sheet.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync =
        ref.watch(productsStreamProvider);

    return Container(
      color: BinanceTheme.canvasDark,
      padding:
          const EdgeInsets.all(BinanceTheme.spaceLg),
      child: productsAsync.when(
        data: (products) => GridView.builder(
          gridDelegate:
              const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            childAspectRatio: 1.25,
            crossAxisSpacing: BinanceTheme.spaceMd,
            mainAxisSpacing: BinanceTheme.spaceMd,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return Material(
              color: BinanceTheme.surfaceCardDark,
              borderRadius: BinanceTheme.roundedLg,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  final modelProduct = models.Product(
                    id: product.id,
                    name: product.name,
                    basePrice: product.basePrice,
                    categoryId: product.categoryId,
                    imageUrl: product.imageUrl,
                  );
                  ModifierBottomSheet.show(
                      context, modelProduct);
                },
                splashColor: BinanceTheme.primary
                    .withValues(alpha: 0.1),
                highlightColor:
                    BinanceTheme.surfaceElevatedDark,
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
                  padding: const EdgeInsets.all(
                      BinanceTheme.spaceMd),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style:
                              BinanceTheme.titleStyle(
                            size: 13,
                            weight: FontWeight.w600,
                            color: BinanceTheme.body,
                          ),
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                      Align(
                        alignment:
                            Alignment.bottomRight,
                        child: Text(
                          '₱${product.basePrice.toStringAsFixed(0)}',
                          style: BinanceTheme
                              .numberStyle(
                            size: 14,
                            weight: FontWeight.w600,
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
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style:
                TextStyle(color: BinanceTheme.muted),
          ),
        ),
      ),
    );
  }
}
