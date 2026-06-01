import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../theme/binance_theme.dart';
import 'checkout_modal.dart';

class OrderTicket extends ConsumerWidget {
  const OrderTicket({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      color: BinanceTheme.surfaceCardDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(BinanceTheme.spaceLg),
            child: Text(
              'Current Order',
              style: BinanceTheme.titleStyle(size: 16, weight: FontWeight.bold),
            ),
          ),
          const Divider(color: BinanceTheme.surfaceElevatedDark, height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: cart.length,
              separatorBuilder: (context, index) => const Divider(
                color: BinanceTheme.surfaceElevatedDark,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = cart[index];
                final modsText = item.selectedModifiers.map((m) => m.name).join(', ');
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: BinanceTheme.spaceLg,
                    vertical: BinanceTheme.spaceXs,
                  ),
                  title: Text(
                    item.product.name,
                    style: BinanceTheme.titleStyle(size: 14, color: BinanceTheme.body),
                  ),
                  subtitle: modsText.isNotEmpty
                      ? Text(
                          modsText,
                          style: BinanceTheme.titleStyle(size: 12, color: BinanceTheme.muted),
                        )
                      : null,
                  trailing: Text(
                    '₱${item.calculatedPrice.toStringAsFixed(2)}',
                    style: BinanceTheme.numberStyle(size: 14, color: BinanceTheme.body),
                  ),
                );
              },
            ),
          ),
          const Divider(color: BinanceTheme.surfaceElevatedDark, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BinanceTheme.spaceMd,
              vertical: BinanceTheme.spaceLg,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: BinanceTheme.titleStyle(size: 16, weight: FontWeight.bold, color: BinanceTheme.muted),
                    ),
                    Text(
                      '₱${cartNotifier.total.toStringAsFixed(2)}',
                      style: BinanceTheme.numberStyle(size: 18, weight: FontWeight.bold, color: BinanceTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: BinanceTheme.spaceLg),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BinanceTheme.primary,
                      foregroundColor: BinanceTheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BinanceTheme.roundedMd,
                      ),
                      elevation: 0,
                    ),
                    onPressed: cart.isNotEmpty
                        ? () => showDialog(
                              context: context,
                              builder: (context) => const CheckoutModal(),
                            )
                        : null,
                    child: Text(
                      'Pay Now',
                      style: BinanceTheme.titleStyle(
                        size: 16,
                        weight: FontWeight.bold,
                        color: BinanceTheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
