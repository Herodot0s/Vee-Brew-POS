import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../models/order_item.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../services/printer_service.dart';
import '../services/receipt_generator.dart';
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
  final _printerService = PrinterService();

  Future<void> _handlePayment(String method) async {
    setState(() => _isProcessing = true);

    try {
      final cartSnapshot = ref.read(cartProvider);
      final total = ref.read(cartTotalProvider);
      final orderNumber =
          await ref.read(checkoutServiceProvider).processCheckout(method);

      if (!mounted) return;

      // Brief visual confirmation
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment Successful — $orderNumber',
            style: BinanceTheme.titleStyle(color: Colors.white),
          ),
          backgroundColor: BinanceTheme.tradingUp,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      _showPrintOption(context, orderNumber, cartSnapshot, total);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment failed: $e',
            style: BinanceTheme.titleStyle(color: Colors.white),
          ),
          backgroundColor: BinanceTheme.tradingDown,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPrintOption(BuildContext context, String orderNumber,
      List<OrderItem> items, double total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: BinanceTheme.surfaceCardDark,
        title: Text('Checkout Complete',
            style: BinanceTheme.titleStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order $orderNumber processed successfully.',
                style: BinanceTheme.titleStyle(color: BinanceTheme.muted)),
            const SizedBox(height: BinanceTheme.spaceLg),
            const Icon(Icons.check_circle_outline,
                color: BinanceTheme.tradingUp, size: 64),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialog
              Navigator.of(context).pop(); // Modal
            },
            child: Text('Done',
                style: BinanceTheme.titleStyle(color: BinanceTheme.muted)),
          ),
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BinanceTheme.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                try {
                  final isConnected = await _printerService.isConnected();
                  if (isConnected) {
                    final bytes = await ReceiptGenerator.generateBytes(
                        orderNumber, items, total);
                    await PrintBluetoothThermal.writeBytes(bytes);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  } else {
                    if (context.mounted) {
                      _showPrinterSelection(context, orderNumber, items, total);
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Print Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Print Receipt'),
            ),
        ],
      ),
    );
  }

  void _showPrinterSelection(BuildContext context, String orderNumber,
      List<OrderItem> items, double total) async {
    final devices = await _printerService.getDevices();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BinanceTheme.surfaceCardDark,
        title: Text('Select Printer',
            style: BinanceTheme.titleStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          child: devices.isEmpty
              ? Text('No paired Bluetooth printers found.',
                  style: BinanceTheme.titleStyle(color: BinanceTheme.muted))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      title: Text(device.name,
                          style: BinanceTheme.titleStyle(color: Colors.white)),
                      subtitle: Text(device.macAdress,
                          style: BinanceTheme.titleStyle(
                              color: BinanceTheme.muted, size: 12)),
                      onTap: () async {
                        try {
                          final connected = await _printerService.connect(device.macAdress);
                          if (connected) {
                            final bytes = await ReceiptGenerator.generateBytes(
                                orderNumber, items, total);
                            await PrintBluetoothThermal.writeBytes(bytes);
                            if (context.mounted) {
                              Navigator.of(context).pop(); // Printer selection
                              Navigator.of(context).pop(); // Success dialog
                              Navigator.of(context).pop(); // Modal
                            }
                          } else {
                             if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not connect to printer')),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Printer Error: $e')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
        ),
      ),
    );
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
