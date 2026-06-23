import 'package:dio/dio.dart';
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

  Future<void> createProductWithImage({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath, 
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'price': price.toString(),
      };
      if (localImagePath != null && localImagePath.isNotEmpty) {
        final fileName = localImagePath.split('/').last;
        formDataMap['image'] = await MultipartFile.fromFile(
          localImagePath,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await apiClient.dio.post(
        '/menu/products',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Producto creado con éxito con su imagen: ${response.data}');
      }
    } on DioException catch (e) {
      print('Error al subir producto e imagen: ${e.message}');
      throw Exception('No se pudo crear el producto');
    }
  }

  Future<void> createCategoryWithImage({
    required String name,
    required int orderIndex,
    required String? localImagePath,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        'name': name,
        'orderIndex': orderIndex.toString(),
      };

      if (localImagePath != null && localImagePath.isNotEmpty) {
        final fileName = localImagePath.split('/').last;
        formDataMap['image'] = await MultipartFile.fromFile(
          localImagePath,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await apiClient.dio.post(
        '/menu/categories',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Categoría creada con éxito con su imagen: ${response.data}');
      }
    } on DioException catch (e) {
      print('Error al subir categoría e imagen: ${e.message}');
      throw Exception('No se pudo crear la categoría');
    }
  }
}

