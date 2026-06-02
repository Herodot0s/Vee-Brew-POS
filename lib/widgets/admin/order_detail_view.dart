import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../providers/admin_provider.dart';
import '../../theme/binance_theme.dart';

class OrderDetailView extends ConsumerWidget {
  final int orderId;
  const OrderDetailView({super.key, required this.orderId});

  String _formatModifiers(String jsonStr) {
    if (jsonStr.isEmpty) return '';
    try {
      final List<dynamic> mods = jsonDecode(jsonStr);
      return mods.map((m) => m['name'] ?? m['id'] ?? '').where((s) => s.isNotEmpty).join(', ');
    } catch (_) {
      return jsonStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(orderItemsProvider(orderId));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No items found',
                style: TextStyle(color: BinanceTheme.muted),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((wrapper) {
              final item = wrapper.item;
              final product = wrapper.product;
              final mods = _formatModifiers(item.selectedModifiers);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${product.name}',
                            style: BinanceTheme.titleStyle,
                          ),
                        ),
                        Text(
                          '₱${item.priceAtTime.toStringAsFixed(2)}',
                          style: BinanceTheme.numberStyle,
                        ),
                      ],
                    ),
                    if (mods.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                        child: Text(
                          'Modifiers: $mods',
                          style: const TextStyle(
                            color: BinanceTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: BinanceTheme.primary),
          ),
        ),
        error: (e, stack) => Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: BinanceTheme.error, size: 40),
              const SizedBox(height: 8),
              Text(
                'Failed to load items: $e',
                style: const TextStyle(color: BinanceTheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
