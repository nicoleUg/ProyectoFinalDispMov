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
    final items = await getCartItemsUseCase.call();
    emit(CartState(items: items, isLoading: false));
  }

  Future<void> addItem(CartItemEntity item) async {
    await addToCartUseCase.call(item);
    await loadCart();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await updateQuantityUseCase.call(productId, quantity);
    await loadCart();
  }

  Future<void> clearCart() async {
    await clearCartUseCase.call();
    await loadCart();
  }
}