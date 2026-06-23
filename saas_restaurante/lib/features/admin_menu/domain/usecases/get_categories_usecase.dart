import '../../../menu/domain/entities/category_entity.dart';
import '../repositories/admin_menu_repository.dart';

class GetCategoriesUseCase {
  final AdminMenuRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() => repository.getCategories();
}
