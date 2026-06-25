import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../Core/database/app_database.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usescases/add_to_cart_usecase.dart';
import '../../domain/usescases/get_cart_items_usecase.dart';
import '../../domain/usescases/update_cart_quantity_usecase.dart';
import '../../domain/usescases/clear_cart_usecase.dart';
import '../../../menu/data/repositories/menu_repository.dart';

class CartState {
  final List<CartItemEntity> items;
  final bool isLoading;
  CartState({required this.items, this.isLoading = false});

  double get total => items.fold(0, (sum, item) => sum + item.totalPrice);
}

class CartCubit extends Cubit<CartState> {
  final AddToCartUseCase addToCartUseCase;
  final GetCartItemsUseCase getCartItemsUseCase;
  final UpdateCartQuantityUseCase updateQuantityUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartCubit({
    required this.addToCartUseCase,
    required this.getCartItemsUseCase,
    required this.updateQuantityUseCase,
    required this.clearCartUseCase,
  }) : super(CartState(items: []));

  Future<void> loadCart() async {
    emit(CartState(items: state.items, isLoading: true));
    try {
      final items = await getCartItemsUseCase.call();
      print('[CartCubit] Carrito cargado exitosamente. Cantidad de items: ${items.length}');
      emit(CartState(items: items, isLoading: false));
    } catch (e, stack) {
      print('[CartCubit] ERROR al cargar el carrito: $e');
      print(stack);
      emit(CartState(items: [], isLoading: false));
    }
  }
  Future<bool> reorderPreviousItems(List<OrderItemEntity> items) async { 
    try {
      print('[CartCubit] reorderPreviousItems iniciado con ${items.length} items');
      for (var it in items) {
        print('[CartCubit] Item a reordenar: productName="${it.productName}", quantity=${it.quantity}');
      }

      final menuRepo = GetIt.instance<MenuRepository>();
      final db = GetIt.instance<AppDatabase>();

      print('[CartCubit] Sincronizando catálogo de productos desde el servidor...');
      final categories = await menuRepo.getCategories();
      
      // Clear local products and categories tables to refresh them
      await db.delete(db.categoriesTable).go();
      await db.delete(db.productsTable).go();

      for (var cat in categories) {
        await db.into(db.categoriesTable).insert(CategoriesTableCompanion.insert(
          id: cat.id,
          name: cat.name,
          imageUrl: Value(cat.imageUrl),
          orderIndex: cat.orderIndex,
        ));

        final products = await menuRepo.getProductsByCategory(cat.id);
        for (var prod in products) {
          await db.into(db.productsTable).insert(ProductsTableCompanion.insert(
            id: prod.id,
            categoryId: cat.id,
            name: prod.name,
            description: prod.description,
            price: prod.price,
            imageUrl: Value(prod.imageUrl),
            isAvailable: Value(prod.isAvailable),
          ));
        }
      }
      print('[CartCubit] Catálogo sincronizado con éxito.');

      await clearCart();

      int itemsAdded = 0;
      for (var item in items) {
        final product = await (db.select(db.productsTable)
              ..where((t) => t.name.equals(item.productName)))
            .getSingleOrNull();

        if (product != null) {
          print('[CartCubit] Producto encontrado en local DB: id=${product.id}, name=${product.name}');
          await addItem(CartItemEntity(
            productId: product.id,
            name: product.name,
            price: product.price,
            quantity: item.quantity,
            imageUrl: product.imageUrl,
          ));
          itemsAdded++;
        } else {
          print('[CartCubit] Producto NO encontrado en local DB para el nombre: "${item.productName}"');
        }
      }

      return itemsAdded > 0;
      
    } catch (e, stack) {
      print("Error al intentar pedir de nuevo: $e");
      print(stack);
      return false;
    }
  }
  Future<void> addItem(CartItemEntity item) async {
    try {
      print('[CartCubit] Intentando añadir item al carrito: ${item.name} (ID: ${item.productId})');
      await addToCartUseCase.call(item);
      print('[CartCubit] Item añadido correctamente a la base de datos');
      await loadCart();
    } catch (e, stack) {
      print('[CartCubit] ERROR al añadir item al carrito: $e');
      print(stack);
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      print('[CartCubit] Intentando actualizar cantidad de ID: $productId a $quantity');
      await updateQuantityUseCase.call(productId, quantity);
      print('[CartCubit] Cantidad actualizada correctamente');
      await loadCart();
    } catch (e, stack) {
      print('[CartCubit] ERROR al actualizar cantidad: $e');
      print(stack);
    }
  }

  Future<void> clearCart() async {
    try {
      print('[CartCubit] Intentando vaciar el carrito');
      await clearCartUseCase.call();
      print('[CartCubit] Carrito vaciado correctamente');
      await loadCart();
    } catch (e, stack) {
      print('[CartCubit] ERROR al vaciar el carrito: $e');
      print(stack);
    }
  }
}