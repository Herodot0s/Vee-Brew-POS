import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/modifier.dart';
import '../models/order_item.dart';
import '../models/mock_data.dart';
import '../providers/cart_provider.dart';
import '../theme/binance_theme.dart';

class ModifierBottomSheet extends StatefulWidget {
  final Product product;

  const ModifierBottomSheet({super.key, required this.product});

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModifierBottomSheet(product: product),
    );
  }

  @override
  State<ModifierBottomSheet> createState() => _ModifierBottomSheetState();
}

class _ModifierBottomSheetState extends State<ModifierBottomSheet> {
  final Map<String, ModifierOption> _selectedModifiers = {};
  late final List<ModifierGroup> _groups;

  @override
  void initState() {
    super.initState();
    _groups = getModifierGroupsForProduct(widget.product);
    for (var group in _groups) {
      final defaultOption = group.options.firstWhere(
        (opt) => opt.isDefault,
        orElse: () => group.options.first,
      );
      _selectedModifiers[group.id] = defaultOption;
    }
  }

  double get _currentTotalPrice {
    double total = widget.product.basePrice;
    _selectedModifiers.forEach((groupId, option) {
      total += option.priceDelta;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BinanceTheme.surfaceCardDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(BinanceTheme.radiusXl),
          topRight: Radius.circular(BinanceTheme.radiusXl),
        ),
        border: const Border(
          top: BorderSide(color: BinanceTheme.surfaceElevatedDark, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: BinanceTheme.spaceLg,
        right: BinanceTheme.spaceLg,
        top: BinanceTheme.spaceLg,
        bottom: BinanceTheme.spaceLg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: BinanceTheme.titleStyle(size: 18, weight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: BinanceTheme.muted),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: BinanceTheme.spaceMd),
          ..._groups.map((group) {
            return Padding(
              padding: const EdgeInsets.only(bottom: BinanceTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    group.name,
                    style: BinanceTheme.titleStyle(
                      size: 14,
                      weight: FontWeight.w600,
                      color: BinanceTheme.muted,
                    ),
                  ),
                  const SizedBox(height: BinanceTheme.spaceXs),
                  Wrap(
                    spacing: BinanceTheme.spaceXs,
                    runSpacing: BinanceTheme.spaceXs,
                    children: group.options.map((opt) {
                      final isSelected = _selectedModifiers[group.id]?.id == opt.id;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              opt.name,
                              style: BinanceTheme.titleStyle(
                                size: 13,
                                color: isSelected ? BinanceTheme.onPrimary : BinanceTheme.body,
                                weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                            if (opt.priceDelta > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(+₱${opt.priceDelta.toStringAsFixed(0)})',
                                style: BinanceTheme.numberStyle(
                                  size: 12,
                                  color: isSelected ? BinanceTheme.onPrimary : BinanceTheme.primary,
                                ),
                              ),
                            ]
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: BinanceTheme.primary,
                        backgroundColor: BinanceTheme.surfaceElevatedDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BinanceTheme.roundedMd,
                          side: BorderSide(
                            color: isSelected ? BinanceTheme.primary : BinanceTheme.surfaceElevatedDark,
                            width: 1,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedModifiers[group.id] = opt;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: BinanceTheme.spaceMd),
          Consumer(
            builder: (context, ref, child) {
              return SizedBox(
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
                  onPressed: () {
                    final item = OrderItem(
                      product: widget.product,
                      selectedModifiers: _selectedModifiers.values.toList(),
                    );
                    ref.read(cartProvider.notifier).addConfiguredItem(item);
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add to Ticket',
                        style: BinanceTheme.titleStyle(
                          size: 16,
                          weight: FontWeight.bold,
                          color: BinanceTheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: BinanceTheme.spaceXs),
                      Text(
                        '₱${_currentTotalPrice.toStringAsFixed(2)}',
                        style: BinanceTheme.numberStyle(
                          size: 16,
                          weight: FontWeight.bold,
                          color: BinanceTheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
