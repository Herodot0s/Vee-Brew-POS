// lib/widgets/analytics/components/top_products_card.dart
import 'package:flutter/material.dart';
import '../../admin/bento_card.dart';

class TopProductsCard extends StatelessWidget {
  final Map<String, ({int quantity, double revenue})> topProducts;

  const TopProductsCard({super.key, required this.topProducts});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = topProducts.entries.toList()
      ..sort((a, b) => b.value.revenue.compareTo(a.value.revenue));
    final displayEntries = sortedEntries.take(5).toList();

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Top 5 Products',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: displayEntries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = displayEntries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}. ${entry.key}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Text('${entry.value.quantity}x', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(width: 8),
                          Text('\$${entry.value.revenue.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
