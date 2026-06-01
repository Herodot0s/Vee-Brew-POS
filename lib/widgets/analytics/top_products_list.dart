import 'package:flutter/material.dart';
import '../../theme/binance_theme.dart';

class ProductStat {
  final String name;
  final int quantity;

  ProductStat({required this.name, required this.quantity});
}

class TopProductsList extends StatelessWidget {
  final List<ProductStat> products;

  const TopProductsList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BinanceTheme.surfaceCardDark,
        borderRadius: BinanceTheme.roundedXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(BinanceTheme.spaceMd),
            child: Text(
              'Top Products',
              style: BinanceTheme.titleStyle(
                size: 14,
                weight: FontWeight.w600,
                color: BinanceTheme.body,
              ),
            ),
          ),
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BinanceTheme.spaceMd,
                vertical: BinanceTheme.spaceXs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: BinanceTheme.titleStyle(
                      size: 14,
                      weight: FontWeight.w400,
                      color: BinanceTheme.muted,
                    ),
                  ),
                  Text(
                    '${product.quantity}',
                    style: BinanceTheme.numberStyle(
                      size: 14,
                      weight: FontWeight.w600,
                      color: BinanceTheme.onDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
