import '../repositories/admin_menu_repository.dart';

class CreateProductUseCase {
  final AdminMenuRepository repository;

  CreateProductUseCase(this.repository);

  Future<void> call({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
  }) =>
      repository.createProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        localImagePath: localImagePath,
      );
}
