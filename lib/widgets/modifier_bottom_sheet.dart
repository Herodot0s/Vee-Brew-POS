import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/modifier.dart';
import '../models/order_item.dart';
import '../providers/cart_provider.dart';
import '../providers/data_providers.dart';
import '../theme/binance_theme.dart';

class ModifierBottomSheet extends ConsumerStatefulWidget {
  final Product product;
  final int? editIndex;
  final OrderItem? editItem;

  const ModifierBottomSheet({
    super.key,
    required this.product,
    this.editIndex,
    this.editItem,
  });

  static void show(BuildContext context, Product product, {int? editIndex, OrderItem? editItem}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModifierBottomSheet(
        product: product,
        editIndex: editIndex,
        editItem: editItem,
      ),
    );
  }

  @override
  ConsumerState<ModifierBottomSheet> createState() => _ModifierBottomSheetState();
}

class _ModifierBottomSheetState extends ConsumerState<ModifierBottomSheet> {
  final Map<String, Set<String>> _selectedModifierIds = {};
  bool _isInitialized = false;

  void _ensureInitialized(List<ModifierGroup> groups) {
    if (_isInitialized) return;
    if (widget.editItem != null) {
      for (var group in groups) {
        final selectedForGroup = widget.editItem!.selectedModifiers
            .where((opt) => opt.groupId == group.id)
            .map((opt) => opt.id)
            .toSet();
        
        if (group.isMultiSelect) {
          _selectedModifierIds[group.id] = selectedForGroup;
        } else {
          if (selectedForGroup.isNotEmpty) {
            _selectedModifierIds[group.id] = selectedForGroup;
          } else {
            final defaultOption = group.options.firstWhere(
              (opt) => opt.isDefault,
              orElse: () => group.options.first,
            );
            _selectedModifierIds[group.id] = {defaultOption.id};
          }
        }
      }
    } else {
      for (var group in groups) {
        if (group.isMultiSelect) {
          _selectedModifierIds[group.id] = {};
        } else {
          final defaultOption = group.options.firstWhere(
            (opt) => opt.isDefault,
            orElse: () => group.options.first,
          );
          _selectedModifierIds[group.id] = {defaultOption.id};
        }
      }
    }
    _isInitialized = true;
  }

  double _calculateTotalPrice(List<ModifierGroup> groups) {
    double total = widget.product.basePrice;
    for (var group in groups) {
      final selectedIds = _selectedModifierIds[group.id] ?? {};
      for (var opt in group.options) {
        if (selectedIds.contains(opt.id)) {
          total += opt.priceDelta;
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final modifiersAsync = ref.watch(productModifiersProvider(widget.product.id));

    return modifiersAsync.when(
      loading: () => Container(
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
        padding: const EdgeInsets.all(BinanceTheme.spaceLg),
        child: const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: BinanceTheme.primary),
          ),
        ),
      ),
      error: (error, stack) => Container(
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
        padding: const EdgeInsets.all(BinanceTheme.spaceLg),
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Error: $error',
              style: TextStyle(color: BinanceTheme.muted),
            ),
          ),
        ),
      ),
      data: (groups) {
        _ensureInitialized(groups);

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
                      style: BinanceTheme.titleStyle(
                        size: 18,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: BinanceTheme.muted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: BinanceTheme.spaceMd),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (groups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: BinanceTheme.spaceLg),
                          child: Center(
                            child: Text(
                              'No modifiers available',
                              style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
                            ),
                          ),
                        )
                      else
                        ...groups.map((group) {
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
                                    final isSelected =
                                        _selectedModifierIds[group.id]?.contains(opt.id) ?? false;
                                    return ChoiceChip(
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            opt.name,
                                            style: BinanceTheme.titleStyle(
                                              size: 13,
                                              color: isSelected
                                                  ? BinanceTheme.onPrimary
                                                  : BinanceTheme.body,
                                              weight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                          if (opt.priceDelta > 0) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '(+₱${opt.priceDelta.toStringAsFixed(0)})',
                                              style: BinanceTheme.numberStyle(
                                                size: 12,
                                                color: isSelected
                                                    ? BinanceTheme.onPrimary
                                                    : BinanceTheme.primary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      selected: isSelected,
                                      selectedColor: BinanceTheme.primary,
                                      backgroundColor: BinanceTheme.surfaceElevatedDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BinanceTheme.roundedMd,
                                        side: BorderSide(
                                          color: isSelected
                                              ? BinanceTheme.primary
                                              : BinanceTheme.surfaceElevatedDark,
                                          width: 1,
                                        ),
                                      ),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (group.isMultiSelect) {
                                            final currentSelection =
                                                _selectedModifierIds[group.id] ?? {};
                                            if (selected) {
                                              currentSelection.add(opt.id);
                                            } else {
                                              currentSelection.remove(opt.id);
                                            }
                                            _selectedModifierIds[group.id] = currentSelection;
                                          } else {
                                            if (selected) {
                                              _selectedModifierIds[group.id] = {opt.id};
                                            }
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: BinanceTheme.spaceMd),
              SizedBox(
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
                    final List<ModifierOption> allSelected = [];
                    for (var group in groups) {
                      final selectedIds = _selectedModifierIds[group.id] ?? {};
                      for (var opt in group.options) {
                        if (selectedIds.contains(opt.id)) {
                          allSelected.add(opt);
                        }
                      }
                    }

                    final item = OrderItem(
                      product: widget.product,
                      selectedModifiers: allSelected,
                    );
                    if (widget.editIndex != null) {
                      ref.read(cartProvider.notifier).updateConfiguredItem(widget.editIndex!, item);
                    } else {
                      ref.read(cartProvider.notifier).addConfiguredItem(item);
                    }
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.editIndex != null ? 'Update Item' : 'Add to Ticket',
                        style: BinanceTheme.titleStyle(
                          size: 16,
                          weight: FontWeight.bold,
                          color: BinanceTheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: BinanceTheme.spaceXs),
                      Text(
                        '₱${_calculateTotalPrice(groups).toStringAsFixed(2)}',
                        style: BinanceTheme.numberStyle(
                          size: 16,
                          weight: FontWeight.bold,
                          color: BinanceTheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
