import '../entities/review_entity.dart';

abstract class ReviewsRepository {
  /// Guarda una nueva reseña localmente.
  Future<void> addReview(ReviewEntity review);

  /// Obtiene todas las reseñas de un producto.
  Future<List<ReviewEntity>> getReviewsForProduct(String productId);

  /// Calcula el promedio de calificaciones (0.0 si no hay reseñas).
  Future<double> getAverageRating(String productId);
}
