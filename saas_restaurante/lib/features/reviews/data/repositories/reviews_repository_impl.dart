import 'package:drift/drift.dart';
import '../../../../Core/database/app_database.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final AppDatabase _db;

  ReviewsRepositoryImpl(this._db);

  @override
  Future<void> addReview(ReviewEntity review) async {
    await _db.insertReview(ReviewsTableCompanion(
      productId: Value(review.productId),
      rating: Value(review.rating),
      comment: Value(review.comment),
      userName: Value(review.userName),
      createdAt: Value(review.createdAt),
    ));
  }

  @override
  Future<List<ReviewEntity>> getReviewsForProduct(String productId) async {
    final rows = await _db.getReviewsForProduct(productId);
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<double> getAverageRating(String productId) =>
      _db.getAverageRating(productId);

  ReviewEntity _mapToEntity(ReviewsTableData row) => ReviewEntity(
        id: row.id,
        productId: row.productId,
        rating: row.rating,
        comment: row.comment,
        userName: row.userName,
        createdAt: row.createdAt,
      );
}
