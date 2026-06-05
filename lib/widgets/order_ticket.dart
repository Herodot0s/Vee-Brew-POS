import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../theme/binance_theme.dart';
import 'checkout_modal.dart';
import 'modifier_bottom_sheet.dart';
import '../providers/data_providers.dart';
import '../database/drift_database.dart' show Category;

class OrderTicket extends ConsumerWidget {
  const OrderTicket({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? [];
    final categoryMap = {for (final c in categories) c.id: c.name};

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
                final modsText = item.selectedModifiers
                    .map((m) => m.name)
                    .join(', ');

                final categoryName = categoryMap[item.product.categoryId] ?? 'Unknown';

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      ModifierBottomSheet.show(
                        context,
                        item.product,
                        editIndex: index,
                        editItem: item,
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: BinanceTheme.spaceLg,
                      vertical: BinanceTheme.spaceXs,
                    ),
                    title: Text(
                      '[$categoryName] ${item.product.name}',
                      style: BinanceTheme.titleStyle(
                        size: 14,
                        color: BinanceTheme.body,
                      ),
                    ),
                    subtitle: modsText.isNotEmpty
                        ? Text(
                            modsText,
                            style: BinanceTheme.titleStyle(
                              size: 12,
                              color: BinanceTheme.muted,
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₱${item.calculatedPrice.toStringAsFixed(2)}',
                          style: BinanceTheme.numberStyle(
                            size: 14,
                            color: BinanceTheme.body,
                          ),
                        ),
                        const SizedBox(width: BinanceTheme.spaceMd),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: BinanceTheme.tradingDown,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            cartNotifier.removeItem(index);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Item removed from ticket',
                                  style: BinanceTheme.titleStyle(color: Colors.white),
                                ),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  textColor: BinanceTheme.primary,
                                  onPressed: () {
                                    cartNotifier.undoDelete();
                                  },
                                ),
                                backgroundColor: BinanceTheme.surfaceCardDark,
                                duration: const Duration(seconds: 4),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BinanceTheme.roundedMd,
                                  side: const BorderSide(
                                    color: BinanceTheme.surfaceElevatedDark,
                                    width: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
                      style: BinanceTheme.titleStyle(
                        size: 16,
                        weight: FontWeight.bold,
                        color: BinanceTheme.muted,
                      ),
                    ),
                    Text(
                      '₱${cartNotifier.total.toStringAsFixed(2)}',
                      style: BinanceTheme.numberStyle(
                        size: 18,
                        weight: FontWeight.bold,
                        color: BinanceTheme.primary,
                      ),
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
          ),
        ],
      ),
    );
  }
}
