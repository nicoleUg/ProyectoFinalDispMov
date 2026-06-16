import '../../../../Core/database/app_database.dart';
import 'package:drift/drift.dart';

abstract class MenuLocalDataSource {
  Future<List<CategoriesTableData>> getCategories();
  Future<List<ProductsTableData>> getProductsByCategory(String categoryId);
  Future<void> saveCategories(List<CategoriesTableCompanion> categories);
  Future<void> saveProducts(List<ProductsTableCompanion> products);
}

class MenuLocalDataSourceImpl implements MenuLocalDataSource {
  final AppDatabase db;
  MenuLocalDataSourceImpl(this.db);

  @override
  Future<List<CategoriesTableData>> getCategories() async {
    return await (db.select(db.categoriesTable)..orderBy([(t) => OrderingTerm.asc(t.orderIndex)])).get();
  }

  @override
  Future<List<ProductsTableData>> getProductsByCategory(String categoryId) async {
    return await (db.select(db.productsTable)..where((t) => t.categoryId.equals(categoryId))).get();
  }

  @override
  Future<void> saveCategories(List<CategoriesTableCompanion> categories) async {
    await db.batch((batch) => batch.insertAllOnConflictUpdate(db.categoriesTable, categories));
  }

  @override
  Future<void> saveProducts(List<ProductsTableCompanion> products) async {
    await db.batch((batch) => batch.insertAllOnConflictUpdate(db.productsTable, products));
  }
}