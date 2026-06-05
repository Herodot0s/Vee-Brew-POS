# Design Spec: Receipt Spacing Reduction

This specification details the changes required to remove all explicit vertical spacing feeds from the receipt generation logic in order to minimize paper waste.

## Requirements

1. **Remove Item-Level spacing**:
   Remove the `generator.feed(1)` line that adds spacing between printed cart items.
2. **Remove Payment-Level spacing**:
   Remove the `generator.feed(1)` line between the Total section and the Payment Method section.
3. **Remove Cut-Level spacing**:
   Remove the `generator.feed(2)` line before the printer cuts the receipt, leaving only the cut command.

## Target File
- `lib/services/receipt_generator.dart`

## Verification Criteria
- Unit tests verify that no `feed` byte sequences are emitted by `ReceiptGenerator` in the generated receipt bytes.
