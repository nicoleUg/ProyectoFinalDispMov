import '../../../../Core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class MenuRepository {
  final ApiClient apiClient;

  MenuRepository(this.apiClient);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.dio.get('/menu/categories');
      final List<dynamic> data = response.data;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar las categorías: $e');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final response = await apiClient.dio.get('/menu/products/$categoryId');
      final List<dynamic> data = response.data;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar los productos: $e');
    }
  }
}
