import '../../../orders/domain/entities/order_entity.dart';

abstract class AdminOrdersRepository {
  Future<List<OrderEntity>> getAdminOrders();
  Future<void> updateOrderStatus(String orderId, String newStatus);
}
