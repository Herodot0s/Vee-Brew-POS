import 'package:flutter/material.dart';
import '../../theme/binance_theme.dart';

class RevenueCard extends StatelessWidget {
  final double revenue;

  const RevenueCard({super.key, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BinanceTheme.spaceMd),
      decoration: BoxDecoration(
        color: BinanceTheme.surfaceCardDark,
        borderRadius: BinanceTheme.roundedXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Revenue',
            style: BinanceTheme.titleStyle(
              size: 12,
              weight: FontWeight.w400,
              color: BinanceTheme.muted,
            ),
          ),
          const SizedBox(height: BinanceTheme.spaceXs),
          Text(
            '\$${revenue.toStringAsFixed(2)}',
            style: BinanceTheme.numberStyle(
              size: 24,
              weight: FontWeight.w700,
              color: BinanceTheme.onDark,
            ),
          ),
        ],
      ),
    );
  }
}
