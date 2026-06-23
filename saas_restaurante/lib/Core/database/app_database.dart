import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart'; 

class CartItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
  RealColumn get price => real()();
}

class OrdersTable extends Table {
  TextColumn get id => text()(); 
  RealColumn get total => real()();
  TextColumn get status => text()(); 
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class OrderItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text().references(OrdersTable, #id)();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
}

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductsTable extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(CategoriesTable, #id)(); 
  TextColumn get name => text()();
  TextColumn get description => text()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class ReviewsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productId => text()();
  /// Rating: 1–5 stars
  IntColumn get rating => integer()();
  TextColumn get comment => text().withDefault(const Constant(''))();
  TextColumn get userName => text().withDefault(const Constant('Anónimo'))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [CartItems, CategoriesTable, ProductsTable, OrdersTable, OrderItemsTable, ReviewsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'restauranteX_db'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 4) {
        await m.createTable(reviewsTable);
      }
    },
  );

  // ── Reviews queries ────────────────────────────────────────────────────────

  /// Inserta una nueva reseña.
  Future<int> insertReview(ReviewsTableCompanion review) =>
      into(reviewsTable).insert(review);

  /// Trae todas las reseñas de un producto ordenadas por fecha descendente.
  Future<List<ReviewsTableData>> getReviewsForProduct(String productId) =>
      (select(reviewsTable)
            ..where((r) => r.productId.equals(productId))
            ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
          .get();

  /// Calcula el promedio de estrellas de un producto.
  Future<double> getAverageRating(String productId) async {
    final reviews = await getReviewsForProduct(productId);
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }
}
