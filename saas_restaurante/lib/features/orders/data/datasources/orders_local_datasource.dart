import '../../../../Core/database/app_database.dart';
import 'package:drift/drift.dart';

abstract class OrdersLocalDataSource {
  Future<void> saveOrder(OrdersTableCompanion order, List<OrderItemsTableCompanion> items);
  Future<List<OrdersTableData>> getAllOrders();
  Future<List<OrderItemsTableData>> getItemsForOrder(String orderId);
  Future<List<OrdersTableData>> getUnsyncedOrders();
  Future<void> markAsSynced(String orderId);
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> clearCartTable();
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final AppDatabase db;
  OrdersLocalDataSourceImpl(this.db);

  @override
  Future<void> saveOrder(OrdersTableCompanion order, List<OrderItemsTableCompanion> items) async {
    await db.transaction(() async {
      await db.into(db.ordersTable).insert(order);
      for (var item in items) {
        await db.into(db.orderItemsTable).insert(item);
      }
    });
  }

  @override
  Future<List<OrdersTableData>> getAllOrders() async {
    return await (db.select(db.ordersTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  @override
  Future<List<OrderItemsTableData>> getItemsForOrder(String orderId) async {
    return await (db.select(db.orderItemsTable)..where((t) => t.orderId.equals(orderId))).get();
  }

  @override
  Future<List<OrdersTableData>> getUnsyncedOrders() async {
    return await (db.select(db.ordersTable)..where((t) => t.isSynced.equals(false))).get();
  }

  @override
  Future<void> markAsSynced(String orderId) async {
    await (db.update(db.ordersTable)..where((t) => t.id.equals(orderId)))
        .write(const OrdersTableCompanion(isSynced: Value(true)));
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await (db.update(db.ordersTable)..where((t) => t.id.equals(orderId)))
        .write(OrdersTableCompanion(status: Value(status)));
  }

  @override
  Future<void> clearCartTable() async {
    await db.delete(db.cartItems).go();
  }
}