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

enum CheckoutStep { methodSelection, gcashVerification, cashPayment }

class CheckoutModal extends ConsumerStatefulWidget {
  const CheckoutModal({super.key});

  @override
  ConsumerState<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
  bool _isProcessing = false;
  CheckoutStep _step = CheckoutStep.methodSelection;
  final _printerService = PrinterService();
  final _cashController = TextEditingController();
  final _customerNameController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment(String method, {double? amountReceived, double? changeAmount}) async {
    setState(() => _isProcessing = true);

    try {
      final cartSnapshot = ref.read(cartProvider);
      final total = ref.read(cartTotalProvider);
      final customerName = _customerNameController.text.trim();
      final orderNumber =
          await ref.read(checkoutServiceProvider).processCheckout(
            method,
            amountReceived: amountReceived,
            changeAmount: changeAmount,
            customerName: customerName.isNotEmpty ? customerName : null,
          );

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

      _showPrintOption(
        context,
        orderNumber,
        cartSnapshot,
        total,
        method,
        amountReceived,
        changeAmount,
        customerName.isNotEmpty ? customerName : null,
      );
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

  void _showPrintOption(
    BuildContext context,
    String orderNumber,
    List<OrderItem> items,
    double total,
    String paymentMethod,
    double? amountReceived,
    double? changeAmount,
    String? customerName,
  ) {
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
                      orderNumber,
                      items,
                      total,
                      paymentMethod: paymentMethod,
                      amountReceived: amountReceived,
                      changeAmount: changeAmount,
                      customerName: customerName,
                    );
                    await PrintBluetoothThermal.writeBytes(bytes);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  } else {
                    if (context.mounted) {
                      _showPrinterSelection(
                        context,
                        orderNumber,
                        items,
                        total,
                        paymentMethod,
                        amountReceived,
                        changeAmount,
                        customerName,
                      );
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

  void _showPrinterSelection(
    BuildContext context,
    String orderNumber,
    List<OrderItem> items,
    double total,
    String paymentMethod,
    double? amountReceived,
    double? changeAmount,
    String? customerName,
  ) async {
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
                              orderNumber,
                              items,
                              total,
                              paymentMethod: paymentMethod,
                              amountReceived: amountReceived,
                              changeAmount: changeAmount,
                              customerName: customerName,
                            );
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

        const SizedBox(height: BinanceTheme.spaceLg),

        // Customer Name input field
        TextField(
          controller: _customerNameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Customer Name (Optional)',
            labelStyle: const TextStyle(color: BinanceTheme.muted),
            filled: true,
            fillColor: BinanceTheme.surfaceElevatedDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: BinanceTheme.primary),
            ),
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
                  onTap: () => setState(() => _step = CheckoutStep.cashPayment),
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

  Widget _buildCashPaymentSelection(double total) {
    final enteredValue = double.tryParse(_cashController.text) ?? 0.0;
    final change = enteredValue - total;
    final isValid = enteredValue >= total;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cash Payment',
                style: BinanceTheme.titleStyle(
                  size: 18,
                  weight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: BinanceTheme.muted),
                onPressed: () {
                  _cashController.clear();
                  setState(() => _step = CheckoutStep.methodSelection);
                },
              ),
            ],
          ),
          const SizedBox(height: BinanceTheme.spaceSm),
          Container(height: 1, color: BinanceTheme.surfaceElevatedDark),
          const SizedBox(height: BinanceTheme.spaceMd),

          // Total Amount Due display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total Due:',
                  style: BinanceTheme.titleStyle(color: BinanceTheme.muted, size: 14),
                ),
              ),
              Text(
                '₱${total.toStringAsFixed(2)}',
                style: BinanceTheme.numberStyle(
                  size: 20,
                  weight: FontWeight.bold,
                  color: BinanceTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: BinanceTheme.spaceMd),

          // Text Field for Cash Received
          TextField(
            controller: _cashController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: const TextStyle(color: BinanceTheme.muted),
              prefixText: '₱ ',
              prefixStyle: const TextStyle(color: BinanceTheme.primary, fontSize: 20, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: BinanceTheme.surfaceElevatedDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: BinanceTheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: BinanceTheme.spaceMd),

          // Denominations Quick Buttons
          Wrap(
            spacing: BinanceTheme.spaceSm,
            runSpacing: BinanceTheme.spaceSm,
            children: [
              _buildDenomButton('Exact', null, total),
              _buildDenomButton('₱50', 50.0, total),
              _buildDenomButton('₱100', 100.0, total),
              _buildDenomButton('₱200', 200.0, total),
              _buildDenomButton('₱500', 500.0, total),
              _buildDenomButton('₱1000', 1000.0, total),
            ],
          ),
          const SizedBox(height: BinanceTheme.spaceMd),

          // Change display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Change:',
                  style: BinanceTheme.titleStyle(color: BinanceTheme.muted, size: 14),
                ),
              ),
              Text(
                isValid ? '₱${change.toStringAsFixed(2)}' : '₱0.00',
                style: BinanceTheme.numberStyle(
                  size: 20,
                  weight: FontWeight.bold,
                  color: isValid ? BinanceTheme.tradingUp : BinanceTheme.tradingDown,
                ),
              ),
            ],
          ),
          if (!isValid && _cashController.text.isNotEmpty) ...[
            const SizedBox(height: BinanceTheme.spaceXs),
            Text(
              'Insufficient amount entered',
              style: BinanceTheme.titleStyle(color: BinanceTheme.tradingDown, size: 11),
              textAlign: TextAlign.end,
            ),
          ],

          const SizedBox(height: BinanceTheme.spaceLg),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          _cashController.clear();
                          setState(() => _step = CheckoutStep.methodSelection);
                        },
                  child: Text(
                    'Back',
                    style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
                  ),
                ),
              ),
              const SizedBox(width: BinanceTheme.spaceMd),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BinanceTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: BinanceTheme.spaceMd),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: BinanceTheme.surfaceElevatedDark,
                    disabledForegroundColor: BinanceTheme.muted,
                  ),
                  onPressed: (!isValid || _isProcessing)
                      ? null
                      : () {
                          _handlePayment('Cash', amountReceived: enteredValue, changeAmount: change);
                        },
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          'Confirm',
                          style: BinanceTheme.titleStyle(color: Colors.black, weight: FontWeight.bold, size: 14),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDenomButton(String label, double? value, double total) {
    return InkWell(
      onTap: () {
        if (value == null) {
          _cashController.text = total.toStringAsFixed(2);
        } else {
          _cashController.text = value.toStringAsFixed(2);
        }
        setState(() {});
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: BinanceTheme.spaceMd, vertical: BinanceTheme.spaceSm),
        decoration: BoxDecoration(
          border: Border.all(color: BinanceTheme.surfaceElevatedDark),
          borderRadius: BorderRadius.circular(4),
          color: BinanceTheme.surfaceElevatedDark.withValues(alpha: 0.3),
        ),
        child: Text(
          label,
          style: BinanceTheme.titleStyle(color: Colors.white, size: 14),
        ),
      ),
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
            : _step == CheckoutStep.cashPayment
                ? _buildCashPaymentSelection(total)
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
