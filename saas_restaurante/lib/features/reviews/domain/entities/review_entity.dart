/// Entidad de dominio para una reseña de producto.
class ReviewEntity {
  final int? id;
  final String productId;
  final int rating; // 1–5
  final String comment;
  final String userName;
  final DateTime createdAt;

  ReviewEntity({
    this.id,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.userName,
    required this.createdAt,
  });
}
