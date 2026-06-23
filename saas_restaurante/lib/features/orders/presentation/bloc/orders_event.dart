import '../../../cart/domain/entities/cart_item_entity.dart';

abstract class OrdersEvent {
  const OrdersEvent();
}

class ConfirmOrderRequested extends OrdersEvent {
  final List<CartItemEntity> cartItems;
  final double total;

  const ConfirmOrderRequested({
    required this.cartItems,
    required this.total,
  });
}

class LoadMyOrdersRequested extends OrdersEvent {}
