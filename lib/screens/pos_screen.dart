import 'package:flutter/material.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/product_grid.dart';
import '../widgets/order_ticket.dart';
import '../theme/binance_theme.dart';

class POSScreen extends StatelessWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: BinanceTheme.canvasDark,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: CategorySidebar(),
          ),
          VerticalDivider(width: 1, color: BinanceTheme.surfaceElevatedDark),
          Expanded(
            flex: 5,
            child: ProductGrid(),
          ),
          VerticalDivider(width: 1, color: BinanceTheme.surfaceElevatedDark),
          Expanded(
            flex: 3,
            child: OrderTicket(),
          ),
        ],
      ),
    );
  }
}
