import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/orders_local_datasource.dart';
import '../datasources/orders_remote_datasource.dart';
import '../../../../Core/database/app_database.dart';
import '../../../../Core/secure_storage/secure_storage_service.dart';

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
      tableNumber: Value(order.tableNumber),
      userId: Value(order.userId),
    );

    final itemsCompanions = order.items.map((i) => OrderItemsTableCompanion(
      orderId: Value(order.id),
      productName: Value(i.productName),
      quantity: Value(i.quantity),
    )).toList();

    await localDataSource.saveOrder(orderCompanion, itemsCompanions);

    await localDataSource.clearCartTable();

    await _trySyncSingleOrder(order);
  }

  @override
  Future<List<OrderEntity>> getMyOrders() async {
    final secureStorage = GetIt.instance<SecureStorageService>();
    final token = await secureStorage.getAccessToken();
    String? currentUserId;
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decodedStr = utf8.decode(base64Url.decode(normalized));
          final decodedJson = json.decode(decodedStr);
          currentUserId = decodedJson['sub']?.toString();
        }
      } catch (_) {}
    }

    bool syncSucceeded = false;
    if (currentUserId != null) {
      try {
        final remoteOrders = await remoteDataSource.getMyOrders();
        for (var ro in remoteOrders) {
          final rawId = ro['id']?.toString();
          if (rawId == null) continue;
          final normalizedId = _normalizeUuid(rawId);
          
          final total = (ro['total'] as num?)?.toDouble() ?? 0.0;
          final status = ro['status']?.toString() ?? 'pending';
          final tableNumber = ro['tableNumber'] as int? ?? 0;
          
          DateTime createdAt;
          if (ro['createdAt'] != null) {
            try {
              createdAt = DateTime.parse(ro['createdAt'].toString());
            } catch (_) {
              createdAt = DateTime.now();
            }
          } else {
            createdAt = DateTime.now();
          }

          final orderCompanion = OrdersTableCompanion(
            id: Value(normalizedId),
            total: Value(total),
            status: Value(status),
            createdAt: Value(createdAt),
            isSynced: const Value(true),
            tableNumber: Value(tableNumber),
            userId: Value(currentUserId),
          );

          final List<dynamic> rawItems = ro['items'] ?? [];
          final itemsCompanions = rawItems.map((i) {
            final name = i['name']?.toString() ?? '';
            final qty = i['qty'] as int? ?? 0;
            return OrderItemsTableCompanion(
              orderId: Value(normalizedId),
              productName: Value(name),
              quantity: Value(qty),
            );
          }).toList();

          await localDataSource.upsertRemoteOrder(orderCompanion, itemsCompanions);
        }
        syncSucceeded = true;
      } catch (e) {
        print('Error al sincronizar pedidos remotos: $e');
      }
    }

    final localOrders = await localDataSource.getAllOrders();
    List<OrderEntity> domainOrders = [];

    for (var o in localOrders) {
      // Filter locally by current user ID (allow null for backwards compatibility)
      if (o.userId != null && o.userId != currentUserId) continue;

      String currentStatus = o.status;
      // Sólo sincronizar el estado individualmente desde el servidor si no está entregado localmente y falló el sync general.
      if (o.status != 'delivered' && !syncSucceeded) {
        try {
          final remoteStatus = await remoteDataSource.getOrderStatus(o.id);
          if (remoteStatus != null && remoteStatus != o.status) {
            await localDataSource.updateOrderStatus(o.id, remoteStatus);
            currentStatus = remoteStatus;
          }
        } catch (e) {
          print('Error al sincronizar estado del pedido ${o.id}: $e');
        }
      }

      final localItems = await localDataSource.getItemsForOrder(o.id);
      final items = localItems.map((i) => OrderItemEntity(
        productName: i.productName, quantity: i.quantity
      )).toList();

      domainOrders.add(OrderEntity(
        id: o.id,
        total: o.total,
        status: currentStatus, 
        createdAt: o.createdAt,
        items: items,
        isSynced: o.isSynced,
        tableNumber: o.tableNumber,
        userId: o.userId,
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
        'id': o.id,
        'total': o.total,
        'status': o.status,
        'tableNumber': o.tableNumber,
        'items': localItems.map((i) => {'name': i.productName, 'qty': i.quantity}).toList()
      });
      if (success) {
        await localDataSource.markAsSynced(o.id);
      }
    }
  }

  Future<void> _trySyncSingleOrder(OrderEntity order) async {
    final success = await remoteDataSource.sendOrderToServer({
      'id': order.id,
      'total': order.total,
      'status': order.status,
      'tableNumber': order.tableNumber,
      'items': order.items.map((i) => {'name': i.productName, 'qty': i.quantity}).toList()
    });

    if (success) {
      await localDataSource.markAsSynced(order.id);
    }
  }

  String _normalizeUuid(String uuid) {
    if (uuid.contains('-')) {
      return uuid.toLowerCase();
    }
    if (uuid.length == 32) {
      return '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-${uuid.substring(20)}'.toLowerCase();
    }
    return uuid.toLowerCase();
  }
}