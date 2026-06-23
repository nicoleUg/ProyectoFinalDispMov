import '../../../menu/domain/entities/category_entity.dart';
import '../../../menu/domain/entities/product_entity.dart';

abstract class AdminMenuRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);
  Future<void> createCategory({
    required String name,
    required int orderIndex,
    required String? localImagePath,
  });
  Future<void> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
  });
  Future<void> updateProduct({
    required String productId,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
    required bool isAvailable,
  });
  Future<void> deleteProduct(String productId);
  Future<void> updateCategory({
    required String categoryId,
    required String name,
    required int orderIndex,
    required String? localImagePath,
  });
  Future<void> deleteCategory(String categoryId);
}
