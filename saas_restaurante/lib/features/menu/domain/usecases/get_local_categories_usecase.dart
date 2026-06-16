import '../entities/category_entity.dart';
import '../repositories/menu_repository.dart';

class GetLocalCategoriesUseCase {
  final MenuRepository repository;
  GetLocalCategoriesUseCase(this.repository);
  Future<List<CategoryEntity>> call() => repository.getLocalCategories();
}