import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usescases/add_to_cart_usecase.dart';
import '../../domain/usescases/get_cart_items_usecase.dart';
import '../../domain/usescases/update_cart_quantity_usecase.dart';
import '../../domain/usescases/clear_cart_usecase.dart';

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