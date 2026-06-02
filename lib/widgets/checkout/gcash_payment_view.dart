import 'package:flutter/material.dart';
import '../../theme/binance_theme.dart';

class GCashPaymentView extends StatefulWidget {
  final double amountDue;
  final ValueChanged<String> onConfirm;
  final VoidCallback onCancel;

  const GCashPaymentView({
    super.key,
    required this.amountDue,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<GCashPaymentView> createState() => _GCashPaymentViewState();
}

class _GCashPaymentViewState extends State<GCashPaymentView> {
  final _refController = TextEditingController();

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'GCash Payment',
          style: BinanceTheme.titleStyle(size: 20, weight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: BinanceTheme.spaceLg),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.qr_code_2, size: 100, color: Colors.black),
          ),
        ),
        const SizedBox(height: BinanceTheme.spaceMd),
        Text(
          'Amount Due: ₱${widget.amountDue.toStringAsFixed(2)}',
          style: BinanceTheme.numberStyle(size: 24, weight: FontWeight.bold, color: BinanceTheme.primary),
        ),
        const SizedBox(height: BinanceTheme.spaceLg),
        TextField(
          controller: _refController,
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Reference Number',
            labelStyle: const TextStyle(color: BinanceTheme.muted),
            filled: true,
            fillColor: BinanceTheme.surfaceElevatedDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: BinanceTheme.spaceXl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel', style: TextStyle(color: BinanceTheme.muted)),
              ),
            ),
            const SizedBox(width: BinanceTheme.spaceMd),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BinanceTheme.primary,
                  foregroundColor: Colors.black,
                ),
                onPressed: _refController.text.trim().isEmpty
                    ? null
                    : () => widget.onConfirm(_refController.text.trim()),
                child: const Text('Confirm Payment'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
