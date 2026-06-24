import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
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
      return data.map((json) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(json);
        map['categoryId'] ??= categoryId;
        return ProductModel.fromJson(map);
      }).toList();
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
        final fileName = _getSafeFileName(localImagePath);
        if (kIsWeb) {
          final bytes = await XFile(localImagePath).readAsBytes();
          formDataMap['image'] = MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          );
        } else {
          formDataMap['image'] = await MultipartFile.fromFile(
            localImagePath,
            filename: fileName,
          );
        }
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
      final errorMsg = _getDioErrorMessage(e, 'No se pudo crear el producto');
      print('Error al subir producto e imagen: $errorMsg');
      throw Exception(errorMsg);
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
        final fileName = _getSafeFileName(localImagePath);
        if (kIsWeb) {
          final bytes = await XFile(localImagePath).readAsBytes();
          formDataMap['image'] = MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          );
        } else {
          formDataMap['image'] = await MultipartFile.fromFile(
            localImagePath,
            filename: fileName,
          );
        }
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
      final errorMsg = _getDioErrorMessage(e, 'No se pudo crear la categoría');
      print('Error al subir categoría e imagen: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  Future<void> updateProductWithImage({
    required String productId,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
    required bool isAvailable,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'price': price.toString(),
        'isAvailable': isAvailable.toString(),
      };
      if (localImagePath != null && localImagePath.isNotEmpty) {
        final fileName = _getSafeFileName(localImagePath);
        if (kIsWeb) {
          final bytes = await XFile(localImagePath).readAsBytes();
          formDataMap['image'] = MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          );
        } else {
          formDataMap['image'] = await MultipartFile.fromFile(
            localImagePath,
            filename: fileName,
          );
        }
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await apiClient.dio.patch(
        '/menu/products/$productId',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Producto actualizado con éxito: ${response.data}');
      }
    } on DioException catch (e) {
      final errorMsg = _getDioErrorMessage(e, 'No se pudo actualizar el producto');
      print('Error al actualizar producto: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await apiClient.dio.delete('/menu/products/$productId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Producto eliminado con éxito: ${response.data}');
      }
    } on DioException catch (e) {
      final errorMsg = _getDioErrorMessage(e, 'No se pudo eliminar el producto');
      print('Error al eliminar producto: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  Future<void> updateCategoryWithImage({
    required String categoryId,
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
        final fileName = _getSafeFileName(localImagePath);
        if (kIsWeb) {
          final bytes = await XFile(localImagePath).readAsBytes();
          formDataMap['image'] = MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          );
        } else {
          formDataMap['image'] = await MultipartFile.fromFile(
            localImagePath,
            filename: fileName,
          );
        }
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await apiClient.dio.patch(
        '/menu/categories/$categoryId',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Categoría actualizada con éxito: ${response.data}');
      }
    } on DioException catch (e) {
      final errorMsg = _getDioErrorMessage(e, 'No se pudo actualizar la categoría');
      print('Error al actualizar categoría: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final response = await apiClient.dio.delete('/menu/categories/$categoryId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Categoría eliminada con éxito: ${response.data}');
      }
    } on DioException catch (e) {
      final errorMsg = _getDioErrorMessage(e, 'No se pudo eliminar la categoría');
      print('Error al eliminar categoría: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  String _getDioErrorMessage(DioException e, String defaultMessage) {
    final responseData = e.response?.data;
    String details = '';
    if (responseData is Map && responseData.containsKey('message')) {
      final msg = responseData['message'];
      if (msg is List) {
        details = ': ${msg.join(", ")}';
      } else if (msg is String) {
        details = ': $msg';
      }
    }
    return '$defaultMessage$details';
  }

  String _getSafeFileName(String path) {
    String fileName = path.split(RegExp(r'[/\\]')).last;
    final lowercaseName = fileName.toLowerCase();
    if (!lowercaseName.endsWith('.jpg') &&
        !lowercaseName.endsWith('.jpeg') &&
        !lowercaseName.endsWith('.png') &&
        !lowercaseName.endsWith('.webp') &&
        !lowercaseName.endsWith('.gif')) {
      fileName = '$fileName.jpg';
    }
    return fileName;
  }
}

