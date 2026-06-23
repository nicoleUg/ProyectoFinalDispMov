import '../../../orders/domain/entities/order_entity.dart';
import '../repositories/admin_orders_repository.dart';

class GetAdminOrdersUseCase {
  final AdminOrdersRepository repository;

  GetAdminOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call() async {
    return await repository.getAdminOrders();
  }
}
