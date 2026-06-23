import '../repositories/admin_orders_repository.dart';

class UpdateOrderStatusUseCase {
  final AdminOrdersRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<void> call({required String orderId, required String newStatus}) async {
    return await repository.updateOrderStatus(orderId, newStatus);
  }
}
