import '../../../../Core/database/app_database.dart';
import 'package:drift/drift.dart';

abstract class CartLocalDataSource {
  Future<List<CartItem>> getAllItems();
  Future<void> upsertItem(CartItemsCompanion item);
  Future<void> deleteItem(String productId);
  Future<void> deleteAll();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final AppDatabase db;
  CartLocalDataSourceImpl(this.db);

  @override
  Future<List<CartItem>> getAllItems() => db.select(db.cartItems).get();

  @override
  Future<void> upsertItem(CartItemsCompanion item) async {
    await db.into(db.cartItems).insertOnConflictUpdate(item);
  }

  @override
  Future<void> deleteItem(String productId) => 
      (db.delete(db.cartItems)..where((t) => t.productId.equals(productId))).go();

  @override
  Future<void> deleteAll() => db.delete(db.cartItems).go();
}