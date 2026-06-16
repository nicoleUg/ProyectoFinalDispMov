import 'package:drift/drift.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasource/menu_local_datasource.dart';
import '../datasource/menu_remote_datasource.dart';
import '../../../../Core/database/app_database.dart'; 

class MenuRepositoryImpl implements MenuRepository {
  final MenuLocalDataSource localDataSource;
  final MenuRemoteDataSource remoteDataSource;

  MenuRepositoryImpl({required this.localDataSource, required this.remoteDataSource});

  @override
  Future<List<CategoryEntity>> getLocalCategories() async {
    final localData = await localDataSource.getCategories();
    return localData.map((c) => CategoryEntity(
      id: c.id, name: c.name, imageUrl: c.imageUrl, orderIndex: c.orderIndex
    )).toList();
  }

  @override
  Future<List<ProductEntity>> getLocalProductsByCategory(String categoryId) async {
    final localData = await localDataSource.getProductsByCategory(categoryId);
    return localData.map((p) => ProductEntity(
      id: p.id, categoryId: p.categoryId, name: p.name, 
      description: p.description, price: p.price, imageUrl: p.imageUrl, isAvailable: p.isAvailable
    )).toList();
  }

  @override
  Future<void> syncMenuWithServer() async {
    try {
      final remoteData = await remoteDataSource.fetchMenu();
      
      final categoriesToInsert = (remoteData['categories'] as List).map((json) => CategoriesTableCompanion(
        id: Value(json['id']),
        name: Value(json['name']),
        imageUrl: Value(json['imageUrl']),
        orderIndex: Value(json['orderIndex']),
      )).toList();

      final productsToInsert = (remoteData['products'] as List).map((json) => ProductsTableCompanion(
        id: Value(json['id']),
        categoryId: Value(json['categoryId']),
        name: Value(json['name']),
        description: Value(json['description']),
        price: Value(json['price'].toDouble()),
        imageUrl: Value(json['imageUrl']),
        isAvailable: Value(json['isAvailable']),
      )).toList();

      await localDataSource.saveCategories(categoriesToInsert);
      await localDataSource.saveProducts(productsToInsert);
      
    } catch (e) {
      print("Error sincronizando menú: $e");
    }
  }
}