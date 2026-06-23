import '../../../../Core/database/app_database.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final AppDatabase _database;

  FavoritesRepositoryImpl(this._database);

  @override
  Future<void> addFavorite(String productId) async {
    await _database.addFavorite(productId);
  }

  @override
  Future<void> removeFavorite(String productId) async {
    await _database.removeFavorite(productId);
  }

  @override
  Future<bool> isFavorite(String productId) async {
    return await _database.isFavorite(productId);
  }

  @override
  Future<List<FavoriteEntity>> getFavorites() async {
    final rows = await _database.getAllFavorites();
    return rows
        .map((row) => FavoriteEntity(
              id: row.id,
              productId: row.productId,
              addedAt: row.addedAt,
            ))
        .toList();
  }
}
