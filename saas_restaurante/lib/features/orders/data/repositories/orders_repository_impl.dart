import 'package:drift/drift.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasource/orders_local_datasource.dart';
import '../datasource/orders_remote_datasource.dart';
import '../../../../Core/database/app_database.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrdersLocalDataSource localDataSource;
  final OrdersRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.localDataSource, required this.remoteDataSource});

  @override
  Future<void> createOrder(OrderEntity order) async {
    final orderCompanion = OrdersTableCompanion(
      id: Value(order.id),
      total: Value(order.total),
      status: Value(order.status),
      createdAt: Value(order.createdAt),
      isSynced: const Value(false),
    );

    final itemsCompanions = order.items.map((i) => OrderItemsTableCompanion(
      orderId: Value(order.id),
      productName: Value(i.productName),
      quantity: Value(i.quantity),
    )).toList();

    await localDataSource.saveOrder(orderCompanion, itemsCompanions);

    await localDataSource.clearCartTable();

    _trySyncSingleOrder(order);
  }

  @override
  Future<List<OrderEntity>> getMyOrders() async {
    final localOrders = await localDataSource.getAllOrders();
    List<OrderEntity> domainOrders = [];

    for (var o in localOrders) {
      final localItems = await localDataSource.getItemsForOrder(o.id);
      final items = localItems.map((i) => OrderItemEntity(
        productName: i.productName, quantity: i.quantity
      )).toList();

      domainOrders.add(OrderEntity(
        id: o.id, total: o.total, status: o.status, 
        createdAt: o.createdAt, items: items, isSynced: o.isSynced
      ));
    }
    return domainOrders;
  }

  @override
  Future<void> syncPendingOrders() async {
    final pending = await localDataSource.getUnsyncedOrders();
    for (var o in pending) {
      final localItems = await localDataSource.getItemsForOrder(o.id);
      final success = await remoteDataSource.sendOrderToServer({
        'id': o.id, 'total': o.total, 'status': o.status,
        'items': localItems.map((i) => {'name': i.productName, 'qty': i.quantity}).toList()
      });
      if (success) {
        await localDataSource.markAsSynced(o.id);
      }
    }
  }

  void _trySyncSingleOrder(OrderEntity order) async {
    final success = await remoteDataSource.sendOrderToServer({
      'id': order.id, 'total': order.total, 'status': order.status,
      'items': order.items.map((i) => {'name': i.productName, 'qty': i.quantity}).toList()
    });

    if (success) {
      await localDataSource.markAsSynced(order.id);
    }
  }
}