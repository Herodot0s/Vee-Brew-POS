import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../theme/binance_theme.dart';

class OrderDetailView extends ConsumerWidget {
  final int orderId;
  const OrderDetailView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(orderItemsProvider(orderId));

    return itemsAsync.when(
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.quantity}x Product ID: ${item.productId} - ₱${item.priceAtTime}',
                  style: const TextStyle(color: BinanceTheme.onDark)),
              if (item.selectedModifiers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('Mods: ${item.selectedModifiers}',
                      style: const TextStyle(color: BinanceTheme.muted, fontSize: 12)),
                ),
            ],
          ),
        )).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
