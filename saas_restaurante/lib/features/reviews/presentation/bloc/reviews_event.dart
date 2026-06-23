part of 'reviews_bloc.dart';

abstract class ReviewsEvent {}

/// Carga las reseñas y el promedio de un producto.
class LoadReviewsRequested extends ReviewsEvent {
  final String productId;
  LoadReviewsRequested(this.productId);
}

/// Envía una nueva reseña.
class SubmitReviewRequested extends ReviewsEvent {
  final String productId;
  final int rating;
  final String comment;
  final String userName;
  SubmitReviewRequested({
    required this.productId,
    required this.rating,
    required this.comment,
    required this.userName,
  });
}
