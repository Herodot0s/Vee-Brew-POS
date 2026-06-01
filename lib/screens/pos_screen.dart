import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/product_grid.dart';
import '../widgets/order_ticket.dart';
import '../theme/binance_theme.dart';
import '../providers/admin_provider.dart';
import '../providers/data_providers.dart';
import 'admin_dashboard_screen.dart';

class POSScreen extends ConsumerWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminMode = ref.watch(isAdminModeProvider);
    return Scaffold(
      backgroundColor: BinanceTheme.canvasDark,
      body: Row(
        children: [
          const Expanded(
            flex: 2,
            child: CategorySidebar(),
          ),
          const VerticalDivider(width: 1, color: BinanceTheme.surfaceElevatedDark),
          Expanded(
            flex: 8,
            child: isAdminMode
                ? const AdminDashboardScreen()
                : const Row(
                    children: [
                      Expanded(flex: 5, child: ProductGrid()),
                      VerticalDivider(width: 1, color: BinanceTheme.surfaceElevatedDark),
                      Expanded(flex: 3, child: OrderTicket()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
