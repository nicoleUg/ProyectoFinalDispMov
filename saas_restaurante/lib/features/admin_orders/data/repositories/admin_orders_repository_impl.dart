import 'package:drift/drift.dart';
import '../../../../Core/database/app_database.dart';
import '../../../../Core/network/api_client.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/repositories/admin_orders_repository.dart';

class AdminOrdersRepositoryImpl implements AdminOrdersRepository {
  final AppDatabase db;
  final ApiClient apiClient;

  AdminOrdersRepositoryImpl({required this.db, required this.apiClient});

  @override
  Future<List<OrderEntity>> getAdminOrders() async {
    // 1. Intentar sincronizar desde el backend remoto
    try {
      final response = await apiClient.dio.get('/orders');
      final List<dynamic> data = response.data;
      print('[AdminOrdersRepository] Sincronizando ${data.length} pedidos desde el backend...');

      for (var json in data) {
        final orderId = json['id'] as String;
        final total = (json['total'] as num).toDouble();
        final status = json['status'] as String;
        final tableNumber = json['tableNumber'] as int? ?? 0;
        final createdAt = json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now();

        // Guardar o actualizar pedido local
        await db.into(db.ordersTable).insertOnConflictUpdate(OrdersTableCompanion(
              id: Value(orderId),
              total: Value(total),
              status: Value(status),
              createdAt: Value(createdAt),
              isSynced: const Value(true),
              tableNumber: Value(tableNumber),
            ));

        // Actualizar items locales para este pedido
        await (db.delete(db.orderItemsTable)..where((t) => t.orderId.equals(orderId))).go();

        final List<dynamic> itemsJson = json['items'] as List<dynamic>? ?? [];
        for (var item in itemsJson) {
          await db.into(db.orderItemsTable).insert(OrderItemsTableCompanion(
                orderId: Value(orderId),
                productName: Value(item['name'] as String),
                quantity: Value(item['qty'] as int),
              ));
        }
      }
    } catch (e) {
      print('[AdminOrdersRepository] Advertencia: No se pudieron obtener los pedidos del backend ($e). Usando base de datos local SQLite.');
    }

    // 2. Cargar todos los pedidos desde SQLite
    final localOrders = await (db.select(db.ordersTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    if (localOrders.isEmpty) {
      return [];
    }

    // 4. Mapear a entidades de dominio
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
        tableNumber: o.tableNumber,
      ));
    }
    return domainOrders;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    // 1. Update SQLite local state
    await (db.update(db.ordersTable)..where((t) => t.id.equals(orderId)))
        .write(OrdersTableCompanion(
      status: Value(newStatus),
    ));

    // 2. Try to sync to remote API
    try {
      await apiClient.dio.patch('/orders/$orderId/status', data: {
        'status': newStatus,
      });
      print('Sincronización de pedido $orderId exitosa en el servidor.');
    } catch (e) {
      print('Advertencia: No se pudo sincronizar el estado en el servidor: $e. Operando localmente.');
    }
  }
}
