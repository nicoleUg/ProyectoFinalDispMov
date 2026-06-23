import '../../../menu/data/repositories/menu_repository.dart';
import '../../../menu/domain/entities/category_entity.dart';
import '../../../menu/domain/entities/product_entity.dart';
import '../../domain/repositories/admin_menu_repository.dart';

class AdminMenuRepositoryImpl implements AdminMenuRepository {
  final MenuRepository menuRepository;

  AdminMenuRepositoryImpl({required this.menuRepository});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await menuRepository.getCategories();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    return await menuRepository.getProductsByCategory(categoryId);
  }

  @override
  Future<void> createCategory({
    required String name,
    required int orderIndex,
    required String? localImagePath,
  }) async {
    await menuRepository.createCategoryWithImage(
      name: name,
      orderIndex: orderIndex,
      localImagePath: localImagePath,
    );
  }

  @override
  Future<void> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
  }) async {
    await menuRepository.createProductWithImage(
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      localImagePath: localImagePath,
    );
  }
}
