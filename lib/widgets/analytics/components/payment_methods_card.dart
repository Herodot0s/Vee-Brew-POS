// lib/widgets/analytics/components/payment_methods_card.dart
import 'package:flutter/material.dart';
import '../../admin/bento_card.dart';

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
              const Icon(Icons.payments, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Revenue by Payment Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: paymentMethods.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('\$${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
