# Design Spec: Customer Name on Receipt and POS

This specification details the changes required to allow the cashier to enter a customer's name during checkout, save it in the database, display it on the printed thermal receipt (if provided), and view it in the POS history.

## Requirements

1. **Database Persistence**:
   - Add a nullable `customerName` column to the `Orders` table.
   - Run a migration to upgrade the database schema version to `5`.

2. **POS Checkout flow**:
   - Add a text input field in the `CheckoutModal` to capture the customer name.
   - The field must be optional (cashier can leave it blank).
   - Pass the captured name through the checkout service to be stored in the database.

3. **Receipt Printing**:
   - Update `ReceiptGenerator` to accept the customer's name.
   - If a customer name is present, print a line: `CUSTOMER: <name>` directly below the `ORDER NO` line.
   - If the name is blank or null, omit the `CUSTOMER` line entirely.

4. **POS Order History**:
   - In the POS Admin Dashboard (`_OrderHistoryView`), display `Customer: <name>` for orders that have a customer name saved.

## Affected Files

- `lib/database/drift_database.dart`: Update table schema and migration logic.
- `lib/providers/checkout_provider.dart`: Update checkout service to accept and store the customer name.
- `lib/services/receipt_generator.dart`: Update receipt bytes generation to include the customer name.
- `lib/widgets/checkout_modal.dart`: Add text input field and pass the customer name.
- `lib/screens/admin_dashboard_screen.dart`: Display the customer name in the order history.

## Verification Criteria

- Database tests: Ensure the schema version upgrade works and new columns are accessible.
- Unit tests: Verify `ReceiptGenerator` correctly includes or omits the customer name line.
- Manual UAT: Open the POS, make a purchase with a customer name, verify it appears in the print preview/receipt, and is listed in the Admin order history.
