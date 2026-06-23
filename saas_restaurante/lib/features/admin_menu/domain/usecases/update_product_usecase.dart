import '../repositories/admin_menu_repository.dart';

class UpdateProductUseCase {
  final AdminMenuRepository repository;

  UpdateProductUseCase(this.repository);

  Future<void> call({
    required String productId,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
    required bool isAvailable,
  }) async {
    return await repository.updateProduct(
      productId: productId,
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      localImagePath: localImagePath,
      isAvailable: isAvailable,
    );
  }
}
