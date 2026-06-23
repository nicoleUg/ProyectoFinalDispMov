import '../entities/favorite_entity.dart';

abstract class FavoritesRepository {
  Future<void> addFavorite(String productId);
  Future<void> removeFavorite(String productId);
  Future<bool> isFavorite(String productId);
  Future<List<FavoriteEntity>> getFavorites();
}
