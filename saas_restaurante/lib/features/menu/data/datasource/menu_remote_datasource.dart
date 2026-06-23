import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class MenuRemoteDataSource {
  Future<Map<String, dynamic>> fetchMenu();

  // --- MÉTODOS DE PRODUCTOS ---
  Future<void> createProductWithImage({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
  });

  Future<void> updateProductWithImage({
    required String productId,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
    required bool isAvailable,
  });

  Future<void> deleteProduct(String productId);

  // --- MÉTODOS DE CATEGORÍAS ---
  Future<void> createCategoryWithImage({
    required String name,
    required int orderIndex,
    required String? localImagePath,
  });

  Future<void> updateCategoryWithImage({
    required String categoryId,
    required String name,
    required int orderIndex,
    required String? localImagePath,
  });

  Future<void> deleteCategory(String categoryId);
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;
  MenuRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> fetchMenu() async {
    final response = await dio.get('/menu');
    return response.data;
  }

  // HELPER MÁGICO: Procesa la imagen correctamente en Web (bytes) o Móvil (ruta)
  Future<MultipartFile?> _prepareImage(String? path) async {
    if (path == null || path.isEmpty) return null;
    
    if (kIsWeb) {
      // En Web extraemos los bytes del Blob local temporal
      final response = await Dio().get(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      return MultipartFile.fromBytes(response.data, filename: 'image.jpg');
    } else {
      // En Android/iOS usamos el archivo directamente
      return await MultipartFile.fromFile(path, filename: 'image.jpg');
    }
  }

  @override
  Future<void> createProductWithImage({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
  }) async {
    final imageFile = await _prepareImage(localImagePath);

    final formData = FormData.fromMap({
      'categoryId': categoryId,
      'name': name,
      'description': description,
      // IMPORTANTE: Convierte el número a String para evitar el Error 400
      'price': price.toString(),
      if (imageFile != null) 'image': imageFile,
    });

    await dio.post('/menu/products', data: formData);
  }

  @override
  Future<void> updateProductWithImage({
    required String productId,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String? localImagePath,
    required bool isAvailable,
  }) async {
    final imageFile = await _prepareImage(localImagePath);

    final formData = FormData.fromMap({
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price.toString(),
      'isAvailable': isAvailable.toString(),
      if (imageFile != null) 'image': imageFile,
    });

    await dio.patch('/menu/products/$productId', data: formData);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await dio.delete('/menu/products/$productId');
  }

  @override
  Future<void> createCategoryWithImage({
    required String name,
    required int orderIndex,
    required String? localImagePath,
  }) async {
    final imageFile = await _prepareImage(localImagePath);

    final formData = FormData.fromMap({
      'name': name,
      'orderIndex': orderIndex.toString(),
      if (imageFile != null) 'image': imageFile,
    });

    await dio.post('/menu/categories', data: formData);
  }

  @override
  Future<void> updateCategoryWithImage({
    required String categoryId,
    required String name,
    required int orderIndex,
    required String? localImagePath,
  }) async {
    final imageFile = await _prepareImage(localImagePath);

    final formData = FormData.fromMap({
      'name': name,
      'orderIndex': orderIndex.toString(),
      if (imageFile != null) 'image': imageFile,
    });

    await dio.patch('/menu/categories/$categoryId', data: formData);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await dio.delete('/menu/categories/$categoryId');
  }
}