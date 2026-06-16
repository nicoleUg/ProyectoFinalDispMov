import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class MenuRepository {
  Future<List<CategoryEntity>> getLocalCategories();
  Future<List<ProductEntity>> getLocalProductsByCategory(String categoryId);

  Future<void> syncMenuWithServer();
}