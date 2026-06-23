import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../../../../Core/database/app_database.dart';
import 'package:drift/drift.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  CartRepositoryImpl(this.localDataSource);

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    final items = await localDataSource.getAllItems();
    return items.map((i) => CartItemEntity(
      productId: i.productId, name: i.productName, 
      price: i.price, quantity: i.quantity
    )).toList();
  }

  @override
  Future<void> addToCart(CartItemEntity item) async {
    await localDataSource.upsertItem(CartItemsCompanion(
      productId: Value(item.productId),
      productName: Value(item.name),
      price: Value(item.price),
      quantity: Value(item.quantity),
    ));
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await localDataSource.deleteItem(productId);
    } else {
      final items = await localDataSource.getAllItems();
      final item = items.firstWhere((i) => i.productId == productId);
      await localDataSource.upsertItem(CartItemsCompanion(
        id: Value(item.id),
        productId: Value(productId),
        quantity: Value(quantity),
      ));
    }
  }

  @override
  Future<void> removeFromCart(String productId) => localDataSource.deleteItem(productId);
  @override
  Future<void> clearCart() => localDataSource.deleteAll();
}