abstract class FavoritesEvent {}

class LoadFavoritesRequested extends FavoritesEvent {}

class ToggleFavoriteRequested extends FavoritesEvent {
  final String productId;
  ToggleFavoriteRequested(this.productId);
}
