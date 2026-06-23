import 'package:drift/drift.dart';
import '../../../../Core/database/app_database.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/repositories/admin_orders_repository.dart';

class AdminOrdersRepositoryImpl implements AdminOrdersRepository {
  final AppDatabase db;

  AdminOrdersRepositoryImpl({required this.db});

  @override
  Future<List<OrderEntity>> getAdminOrders() async {
    // 1. Fetch all orders from database
    final localOrders = await (db.select(db.ordersTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    // 2. If empty, seed mock orders for high-fidelity demo
    if (localOrders.isEmpty) {
      await _seedMockOrders();
      // Re-fetch after seeding
      return getAdminOrders();
    }

    // 3. Map database data to domain entities
    List<OrderEntity> domainOrders = [];
    for (var o in localOrders) {
      final localItems = await (db.select(db.orderItemsTable)
            ..where((t) => t.orderId.equals(o.id)))
          .get();

      final items = localItems
          .map((i) => OrderItemEntity(
                productName: i.productName,
                quantity: i.quantity,
              ))
          .toList();

      domainOrders.add(OrderEntity(
        id: o.id,
        total: o.total,
        status: o.status,
        createdAt: o.createdAt,
        items: items,
        isSynced: o.isSynced,
      ));
    }
    return domainOrders;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await (db.update(db.ordersTable)..where((t) => t.id.equals(orderId)))
        .write(OrdersTableCompanion(
      status: Value(newStatus),
    ));
  }

  Future<void> _seedMockOrders() async {
    final now = DateTime.now();

    // Mock Order 1: Pending (Pendiente)
    final order1Id = 'order-mock-001';
    await db.into(db.ordersTable).insert(OrdersTableCompanion(
          id: Value(order1Id),
          total: const Value(15.90),
          status: const Value('pending'),
          createdAt: Value(now.subtract(const Duration(minutes: 15))),
          isSynced: const Value(true),
        ));
    await db.into(db.orderItemsTable).insert(OrderItemsTableCompanion(
          orderId: Value(order1Id),
          productName: const Value('Hamburguesa Doble con Queso'),
          quantity: const Value(1),
        ));
    await db.into(db.orderItemsTable).insert(OrderItemsTableCompanion(
          orderId: Value(order1Id),
          productName: const Value('Papas Fritas Medianas'),
          quantity: const Value(1),
        ));

    // Mock Order 2: Preparing (En Preparación)
    final order2Id = 'order-mock-002';
    await db.into(db.ordersTable).insert(OrdersTableCompanion(
          id: Value(order2Id),
          total: const Value(24.50),
          status: const Value('preparing'),
          createdAt: Value(now.subtract(const Duration(minutes: 25))),
          isSynced: const Value(true),
        ));
    await db.into(db.orderItemsTable).insert(OrderItemsTableCompanion(
          orderId: Value(order2Id),
          productName: const Value('Pizza Pepperoni Familiar'),
          quantity: const Value(1),
        ));
    await db.into(db.orderItemsTable).insert(OrderItemsTableCompanion(
          orderId: Value(order2Id),
          productName: const Value('Gaseosa Coca-Cola 1.5L'),
          quantity: const Value(1),
        ));

    // Mock Order 3: Ready (Listo / Despachado)
    final order3Id = 'order-mock-003';
    await db.into(db.ordersTable).insert(OrdersTableCompanion(
          id: Value(order3Id),
          total: const Value(12.50),
          status: const Value('ready'),
          createdAt: Value(now.subtract(const Duration(minutes: 5))),
          isSynced: const Value(true),
        ));
    await db.into(db.orderItemsTable).insert(OrderItemsTableCompanion(
          orderId: Value(order3Id),
          productName: const Value('Ensalada César con Pollo'),
          quantity: const Value(1),
        ));
    await db.into(db.orderItemsTable).insert(OrderItemsTableCompanion(
          orderId: Value(order3Id),
          productName: const Value('Jugo Natural de Maracuyá'),
          quantity: const Value(1),
        ));
  }
}
