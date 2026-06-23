part of 'reviews_bloc.dart';

abstract class ReviewsState {}

class ReviewsInitial extends ReviewsState {}
class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<ReviewEntity> reviews;
  final double averageRating;
  ReviewsLoaded({required this.reviews, required this.averageRating});
}

/// Reseña enviada exitosamente — se usa para cerrar el diálogo y mostrar feedback.
class ReviewSubmitted extends ReviewsState {
  final List<ReviewEntity> reviews;
  final double averageRating;
  ReviewSubmitted({required this.reviews, required this.averageRating});
}

class ReviewsError extends ReviewsState {
  final String message;
  ReviewsError(this.message);
}
