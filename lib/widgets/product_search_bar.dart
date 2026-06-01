import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';
import '../theme/binance_theme.dart';

class ProductSearchBar extends ConsumerStatefulWidget {
  const ProductSearchBar({super.key});

  @override
  ConsumerState<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends ConsumerState<ProductSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: BinanceTheme.surfaceCardDark,
        borderRadius: BinanceTheme.roundedLg,
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).setQuery(value);
        },
        style: BinanceTheme.titleStyle(
          size: 13,
          weight: FontWeight.w400,
          color: BinanceTheme.body,
        ),
        cursorColor: BinanceTheme.primary,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: BinanceTheme.titleStyle(
            size: 13,
            weight: FontWeight.w400,
            color: BinanceTheme.muted,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: BinanceTheme.muted,
            size: 18,
          ),
          suffixIcon: query.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                  child: const Icon(
                    Icons.clear,
                    color: BinanceTheme.muted,
                    size: 18,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BinanceTheme.roundedLg,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BinanceTheme.roundedLg,
            borderSide: const BorderSide(color: BinanceTheme.primary, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          isDense: true,
        ),
      ),
    );
  }
}
