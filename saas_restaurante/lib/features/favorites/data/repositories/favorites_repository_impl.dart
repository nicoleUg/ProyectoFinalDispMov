import '../../../../Core/database/app_database.dart';
import '../../../../Core/network/api_client.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../../menu/domain/entities/product_entity.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final AppDatabase _database;
  final ApiClient _apiClient;

  FavoritesRepositoryImpl(this._database, this._apiClient);

  @override
  Future<void> addFavorite(String productId) async {
    // 1. Guardar en la base de datos local (Drift/SQLite) para que la UI reaccione rápido
    await _database.addFavorite(productId);
    
    // 2. Sincronizar con el backend
    try {
      await _apiClient.dio.post('/favorites', data: {'productId': productId});
    } catch (e) {
      // Fallback silencioso: Si el backend falla o no hay internet, ya está guardado localmente
    }
  }

  @override
  Future<void> removeFavorite(String productId) async {
    // 1. Eliminar de la base de datos local
    await _database.removeFavorite(productId);
    
    // 2. Eliminar del backend
    try {
      await _apiClient.dio.delete('/favorites/$productId');
    } catch (e) {
      // Fallback silencioso
    }
  }

  @override
  Future<bool> isFavorite(String productId) async {
    // Para validaciones rápidas de UI (como los íconos de corazón), seguimos usando la base local
    return await _database.isFavorite(productId);
  }

  @override
  Future<List<FavoriteEntity>> getFavorites() async {
    try {
      // 1. Intentamos obtener los favoritos directamente desde el servidor
      final response = await _apiClient.dio.get('/favorites');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        
        return data.map((item) {
          final prodData = item['product'];
          ProductEntity? product;
          
          // Si el backend hace un JOIN (populate) y nos trae la info del producto, la guardamos
          if (prodData != null) {
            product = ProductEntity(
              id: prodData['id'],
              categoryId: prodData['categoryId'] ?? '',
              name: prodData['name'],
              description: prodData['description'] ?? '',
              price: (prodData['price'] ?? 0).toDouble(),
              imageUrl: prodData['imageUrl'],
              isAvailable: prodData['isAvailable'] ?? true,
            );
          }
          
          final String productId = prodData != null ? prodData['id'] as String : (item['productId'] ?? '') as String;
          
          return FavoriteEntity(
            id: item['id']?.toString(), // ID del registro en Postgres (String/UUID)
            productId: productId,
            addedAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
            product: product, // Guardamos el producto anidado
          );
        }).toList();
      }
    } catch (e) {
      // 2. Fallback (Modo Offline): Si la llamada al backend falla, leemos de la base local
    }

    // Retorno en caso de estar offline
    final rows = await _database.getAllFavorites();
    return rows
        .map((row) => FavoriteEntity(
              id: row.id.toString(),
              productId: row.productId,
              addedAt: row.addedAt,
            ))
        .toList();
  }
}