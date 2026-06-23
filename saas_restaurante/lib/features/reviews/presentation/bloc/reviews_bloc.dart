import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/reviews_repository.dart';

part 'reviews_event.dart';
part 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final ReviewsRepository _repository;

  ReviewsBloc(this._repository) : super(ReviewsInitial()) {
    on<LoadReviewsRequested>(_onLoad);
    on<SubmitReviewRequested>(_onSubmit);
  }

  Future<void> _onLoad(
    LoadReviewsRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(ReviewsLoading());
    try {
      final reviews = await _repository.getReviewsForProduct(event.productId);
      final avg = await _repository.getAverageRating(event.productId);
      emit(ReviewsLoaded(reviews: reviews, averageRating: avg));
    } catch (e) {
      emit(ReviewsError('Error al cargar reseñas: $e'));
    }
  }

  Future<void> _onSubmit(
    SubmitReviewRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    try {
      await _repository.addReview(ReviewEntity(
        productId: event.productId,
        rating: event.rating,
        comment: event.comment,
        userName: event.userName,
        createdAt: DateTime.now(),
      ));
      // Recargar después de insertar
      final reviews = await _repository.getReviewsForProduct(event.productId);
      final avg = await _repository.getAverageRating(event.productId);
      emit(ReviewSubmitted(reviews: reviews, averageRating: avg));
    } catch (e) {
      emit(ReviewsError('Error al guardar reseña: $e'));
    }
  }
}
