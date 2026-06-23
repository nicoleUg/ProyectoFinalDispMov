import '../../../menu/domain/entities/product_entity.dart';
class FavoriteEntity {
  final int? id;
  final String productId;
  final DateTime addedAt;
  final ProductEntity? product;

  FavoriteEntity({
    this.id,
    required this.productId,
    required this.addedAt,
    this.product, 
  });
}
