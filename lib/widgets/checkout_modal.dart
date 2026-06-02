import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../theme/binance_theme.dart';
import 'checkout/gcash_payment_view.dart';

enum CheckoutStep { methodSelection, gcashVerification }

class CheckoutModal extends ConsumerStatefulWidget {
  const CheckoutModal({super.key});

  @override
  ConsumerState<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
  bool _isProcessing = false;
  CheckoutStep _step = CheckoutStep.methodSelection;

  Future<void> _handlePayment(String method) async {
    setState(() => _isProcessing = true);

    try {
      await ref.read(checkoutServiceProvider).processCheckout(method);

      if (!mounted) return;

      // Brief visual confirmation
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment Successful — $method',
            style: BinanceTheme.titleStyle(color: Colors.white),
          ),
          backgroundColor: BinanceTheme.tradingUp,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment failed. Try again.',
            style: BinanceTheme.titleStyle(color: Colors.white),
          ),
          backgroundColor: BinanceTheme.tradingDown,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildMethodSelection(double total, int cartLength) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Checkout',
              style: BinanceTheme.titleStyle(
                size: 20,
                weight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${cartLength} item${cartLength == 1 ? '' : 's'}',
              style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
            ),
          ],
        ),

        const SizedBox(height: BinanceTheme.spaceLg),

        // Divider
        Container(height: 1, color: BinanceTheme.surfaceElevatedDark),

        const SizedBox(height: BinanceTheme.spaceLg),

        // Amount
        Text(
          'Amount Due',
          style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
        ),
        const SizedBox(height: BinanceTheme.spaceXs),
        Text(
          '₱${total.toStringAsFixed(2)}',
          style: BinanceTheme.numberStyle(
            size: 48,
            weight: FontWeight.bold,
            color: BinanceTheme.primary,
          ),
        ),

        const SizedBox(height: BinanceTheme.spaceXl),

        // Payment buttons or spinner
        if (_isProcessing)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: BinanceTheme.spaceLg),
            child: CircularProgressIndicator(color: BinanceTheme.primary),
          )
        else
          Row(
            children: [
              Expanded(
                child: _PaymentButton(
                  label: 'CASH',
                  icon: Icons.payments_outlined,
                  onTap: () => _handlePayment('Cash'),
                ),
              ),
              const SizedBox(width: BinanceTheme.spaceMd),
              Expanded(
                child: _PaymentButton(
                  label: 'CARD',
                  icon: Icons.credit_card_outlined,
                  onTap: () => _handlePayment('Card'),
                ),
              ),
              const SizedBox(width: BinanceTheme.spaceMd),
              Expanded(
                child: _PaymentButton(
                  label: 'GCASH',
                  icon: Icons.qr_code_scanner,
                  onTap: () => setState(() => _step = CheckoutStep.gcashVerification),
                ),
              ),
            ],
          ),

        const SizedBox(height: BinanceTheme.spaceLg),

        // Cancel
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isProcessing
                ? null
                : () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);
    final cart = ref.watch(cartProvider);

    return Dialog(
      backgroundColor: BinanceTheme.surfaceCardDark,
      shape: RoundedRectangleBorder(borderRadius: BinanceTheme.roundedXl),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(BinanceTheme.spaceXl),
        child: _step == CheckoutStep.gcashVerification
            ? GCashPaymentView(
                amountDue: total,
                onConfirm: (refNumber) => _handlePayment('GCash'),
                onCancel: () => setState(() => _step = CheckoutStep.methodSelection),
              )
            : _buildMethodSelection(total, cart.length),
      ),
    );
  }
}

class _PaymentButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PaymentButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<_PaymentButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: BinanceTheme.spaceLg),
          decoration: BoxDecoration(
            color: _hovering
                ? BinanceTheme.surfaceElevatedDark
                : Colors.transparent,
            border: Border.all(
              color: _hovering
                  ? BinanceTheme.primary.withValues(alpha: 0.4)
                  : BinanceTheme.surfaceElevatedDark,
            ),
            borderRadius: BinanceTheme.roundedLg,
          ),
          child: Column(
            children: [
              Icon(widget.icon, size: 32, color: Colors.white),
              const SizedBox(height: BinanceTheme.spaceXs),
              Text(
                widget.label,
                style: BinanceTheme.titleStyle(
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
