import 'package:drift/drift.dart';
import 'package:dio/dio.dart';
import '../../../../Core/database/app_database.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final AppDatabase _db;
  final Dio _dio;

  ReviewsRepositoryImpl(this._db, this._dio);

  @override
  Future<void> addReview(ReviewEntity review) async {
    // 1. Guardar localmente
    await _db.insertReview(ReviewsTableCompanion(
      productId: Value(review.productId),
      rating: Value(review.rating),
      comment: Value(review.comment),
      userName: Value(review.userName),
      createdAt: Value(review.createdAt),
    ));

    // 2. Sincronizar con el backend
    try {
      await _dio.post('/reviews', data: {
        'rating': review.rating,
        'comment': review.comment.trim().isEmpty ? '-' : review.comment.trim(),
        'productId': review.productId,
      });
      print('[ReviewsRepository] Reseña enviada correctamente al backend');
    } catch (e) {
      print('[ReviewsRepository] Error al sincronizar reseña con el backend: $e');
      rethrow;
    }
  }

  @override
  Future<List<ReviewEntity>> getReviewsForProduct(String productId) async {
    try {
      final response = await _dio.get('/reviews/$productId');
      final List<dynamic> data = response.data;
      
      print('[ReviewsRepository] Reseñas cargadas desde el backend: ${data.length}');
      return data.map((json) => ReviewEntity(
        id: null,
        productId: productId,
        rating: json['rating'] as int,
        comment: json['comment'] as String,
        userName: (json['user']?['name'] ?? 'Anónimo') as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      )).toList();
    } catch (e) {
      print('[ReviewsRepository] Error al cargar reseñas del backend (usando SQLite local): $e');
      final rows = await _db.getReviewsForProduct(productId);
      return rows.map(_mapToEntity).toList();
    }
  }

  @override
  Future<double> getAverageRating(String productId) async {
    try {
      final reviews = await getReviewsForProduct(productId);
      if (reviews.isEmpty) return 0.0;
      final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
      return total / reviews.length;
    } catch (e) {
      return _db.getAverageRating(productId);
    }
  }

  ReviewEntity _mapToEntity(ReviewsTableData row) => ReviewEntity(
        id: row.id,
        productId: row.productId,
        rating: row.rating,
        comment: row.comment,
        userName: row.userName,
        createdAt: row.createdAt,
      );
}
