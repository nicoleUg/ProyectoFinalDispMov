import '../entities/product_entity.dart';
import '../repositories/menu_repository.dart';

class GetLocalProductsUseCase {
  final MenuRepository repository;
  GetLocalProductsUseCase(this.repository);
  Future<List<ProductEntity>> call(String categoryId) => repository.getLocalProductsByCategory(categoryId);
}