import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mock_data.dart';
import '../providers/category_provider.dart';
import '../theme/binance_theme.dart';

class CategorySidebar extends ConsumerWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      color: BinanceTheme.canvasDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: BinanceTheme.spaceLg,
              horizontal: BinanceTheme.spaceMd,
            ),
            child: Text(
              'VEEBREW',
              style: BinanceTheme.titleStyle(
                size: 20,
                weight: FontWeight.bold,
                color: BinanceTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockCategories.length,
              itemBuilder: (context, index) {
                final cat = mockCategories[index];
                final isSelected = selectedCategory == cat.id;

                return GestureDetector(
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).setCategory(cat.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(
                      vertical: BinanceTheme.spaceXxs,
                      horizontal: BinanceTheme.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? BinanceTheme.surfaceCardDark
                          : Colors.transparent,
                      borderRadius: BinanceTheme.roundedLg,
                      border: isSelected
                          ? Border.all(color: BinanceTheme.surfaceElevatedDark, width: 1)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (isSelected)
                          Positioned(
                            left: 0,
                            top: 12,
                            bottom: 12,
                            width: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: BinanceTheme.primary,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: BinanceTheme.spaceMd,
                            horizontal: BinanceTheme.spaceLg,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                cat.icon,
                                color: isSelected
                                    ? BinanceTheme.onDark
                                    : BinanceTheme.muted,
                                size: 20,
                              ),
                              const SizedBox(width: BinanceTheme.spaceSm),
                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: BinanceTheme.titleStyle(
                                    size: 14,
                                    weight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? BinanceTheme.onDark
                                        : BinanceTheme.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
