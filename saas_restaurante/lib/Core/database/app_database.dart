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
  IntColumn get tableNumber => integer().withDefault(const Constant(0))();
  TextColumn get userId => text().nullable()();

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

class FavoritesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productId => text()();
  DateTimeColumn get addedAt => dateTime()();
}

@DriftDatabase(tables: [CartItems, CategoriesTable, ProductsTable, OrdersTable, OrderItemsTable, ReviewsTable, FavoritesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'restauranteX_db',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 4) {
        await m.createTable(reviewsTable);
      }
      if (from < 5) {
        await m.createTable(favoritesTable);
      }
      if (from < 6) {
        await m.addColumn(ordersTable, ordersTable.tableNumber);
      }
      if (from < 7) {
        await m.addColumn(ordersTable, ordersTable.userId);
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

  // ── Favorites queries ──────────────────────────────────────────────────────

  /// Agrega un producto a favoritos.
  Future<int> addFavorite(String productId) =>
      into(favoritesTable).insert(FavoritesTableCompanion.insert(
        productId: productId,
        addedAt: DateTime.now(),
      ));

  /// Remueve un producto de favoritos.
  Future<int> removeFavorite(String productId) =>
      (delete(favoritesTable)..where((f) => f.productId.equals(productId))).go();

  /// Verifica si un producto está en favoritos.
  Future<bool> isFavorite(String productId) async {
    final query = select(favoritesTable)..where((f) => f.productId.equals(productId));
    final result = await query.get();
    return result.isNotEmpty;
  }

  /// Trae todos los favoritos guardados.
  Future<List<FavoritesTableData>> getAllFavorites() =>
      select(favoritesTable).get();
}
