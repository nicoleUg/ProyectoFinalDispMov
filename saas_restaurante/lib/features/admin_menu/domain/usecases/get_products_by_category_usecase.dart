import '../../../menu/domain/entities/product_entity.dart';
import '../repositories/admin_menu_repository.dart';

class GetProductsByCategoryUseCase {
  final AdminMenuRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<List<ProductEntity>> call(String categoryId) =>
      repository.getProductsByCategory(categoryId);
}
