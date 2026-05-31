import 'package:flutter/material.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/product_grid.dart';
import '../widgets/order_ticket.dart';

class POSScreen extends StatelessWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            flex: 2,
            child: CategorySidebar(),
          ),
          const VerticalDivider(width: 1),
          const Expanded(
            flex: 5,
            child: ProductGrid(),
          ),
          const VerticalDivider(width: 1),
          const Expanded(
            flex: 3,
            child: OrderTicket(),
          ),
        ],
      ),
    );
  }
}
