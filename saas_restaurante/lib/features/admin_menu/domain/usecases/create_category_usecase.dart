import '../repositories/admin_menu_repository.dart';

class CreateCategoryUseCase {
  final AdminMenuRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<void> call({
    required String name,
    required int orderIndex,
    required String? localImagePath,
  }) =>
      repository.createCategory(
        name: name,
        orderIndex: orderIndex,
        localImagePath: localImagePath,
      );
}
