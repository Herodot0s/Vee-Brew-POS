import 'package:flutter/material.dart';
import '../../theme/binance_theme.dart';
import 'bento_card.dart';

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = BinanceTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: BinanceTheme.titleStyle(
                  size: 12,
                  weight: FontWeight.w500,
                  color: BinanceTheme.muted,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: BinanceTheme.numberStyle(
              size: 20,
              weight: FontWeight.bold,
              color: BinanceTheme.body,
            ),
          ),
        ],
      ),
    );
  }
}
