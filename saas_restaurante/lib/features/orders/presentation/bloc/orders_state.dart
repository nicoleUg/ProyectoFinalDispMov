import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}
class OrdersLoading extends OrdersState {}
class OrderPlacedSuccess extends OrdersState {
  final String orderId;
  const OrderPlacedSuccess(this.orderId);
}
class MyOrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  const MyOrdersLoaded(this.orders);
}
class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
}