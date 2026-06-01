// lib/widgets/analytics/components/payment_methods_card.dart
import 'package:flutter/material.dart';
import '../../admin/bento_card.dart';
import '../../../theme/binance_theme.dart';

class PaymentMethodsCard extends StatelessWidget {
  final Map<String, double> paymentMethods;

  const PaymentMethodsCard({super.key, required this.paymentMethods});

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Revenue by Payment Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: paymentMethods.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = paymentMethods.entries.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: Theme.of(context).textTheme.bodyMedium),
                      Text('\$${entry.value.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: BinanceTheme.tradingUp)),
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
