import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:veebrew/database/drift_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  test('Database migration and sync flag', () async {
    // Add dummy order
    final id = await db
        .into(db.orders)
        .insert(
          OrdersCompanion.insert(
            orderNumber: '20260601-001',
            totalAmount: 10.0,
            paymentMethod: 'Cash',
            createdAt: DateTime.now(),
            isSynced: const Value(false),
          ),
        );

    var order = await (db.select(
      db.orders,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(order.isSynced, isFalse);

    await (db.update(db.orders)..where((t) => t.id.equals(id))).write(
      const OrdersCompanion(isSynced: Value(true)),
    );

    order = await (db.select(
      db.orders,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(order.isSynced, isTrue);
  });
}
