import '../repositories/admin_menu_repository.dart';

class DeleteProductUseCase {
  final AdminMenuRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> call(String productId) async {
    return await repository.deleteProduct(productId);
  }
}
