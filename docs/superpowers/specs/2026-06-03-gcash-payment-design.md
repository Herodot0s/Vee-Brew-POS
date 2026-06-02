# GCash Payment Integration Design

## Overview
Add GCash as a payment option in the POS checkout flow. It uses a "Show QR & Manual Confirm" approach where the POS displays a static QR code, and the cashier manually enters the customer's GCash reference number before completing the transaction.

## UI Components
**1. Checkout Modal Selection**
- The `CheckoutModal` will be updated to display a third payment method button: `GCASH`.
- It will sit alongside `CASH` and `CARD`.

**2. GCash Payment Screen (Modal View)**
- Upon selecting GCash, the modal transitions to a verification screen instead of immediately processing.
- **Visuals**:
  - Displays a static QR code placeholder image.
  - Shows the total Amount Due prominently.
- **Input**:
  - A text input field labeled "Reference Number".
  - This field is required.
- **Actions**:
  - `Cancel` button (returns to the main checkout method selection).
  - `Confirm Payment` button (enabled only when the reference number field is not empty).

## Data Flow & Architecture
- **State**: The `_CheckoutModalState` will need to track the current view (e.g., `enum CheckoutStep { methodSelection, gcashVerification }`).
- **Processing**: When "Confirm Payment" is tapped, it calls `_handlePayment('GCash')`.
- **Note**: The current `checkoutServiceProvider` simply accepts a `method` string. We will pass `'GCash'` as the method. The reference number is primarily for visual verification by the cashier for this launch; if database modifications are needed to persist the reference number, they will be out of scope for this immediate visual implementation, or added as a metadata field if the current Drift schema supports it. (Assume current string-based method logging is sufficient).

## Error Handling
- The `Confirm Payment` button must remain disabled until text is entered in the reference number field.
- Uses existing `try/catch` block in `_CheckoutModalState._handlePayment` to show success/failure SnackBars.