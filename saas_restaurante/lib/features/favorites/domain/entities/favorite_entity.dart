class FavoriteEntity {
  final int? id;
  final String productId;
  final DateTime addedAt;

  FavoriteEntity({
    this.id,
    required this.productId,
    required this.addedAt,
  });
}
