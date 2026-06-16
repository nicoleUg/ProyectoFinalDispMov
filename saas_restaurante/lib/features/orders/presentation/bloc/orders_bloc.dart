import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart'; 
import 'orders_event.dart';
import 'orders_state.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository repository;

  OrdersBloc(this.repository) : super(OrdersInitial()) {
    on<ConfirmOrderRequested>(_onConfirmOrderRequested);
    on<LoadMyOrdersRequested>(_onLoadMyOrdersRequested);
  }

  Future<void> _onConfirmOrderRequested(ConfirmOrderRequested event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final orderId = const Uuid().v4();

      final orderItems = event.cartItems.map((c) => OrderItemEntity(
        productName: c.name,
        quantity: c.quantity,
      )).toList();
      final newOrder = OrderEntity(
        id: orderId,
        total: event.total,
        status: 'preparing', 
        createdAt: DateTime.now(),
        items: orderItems,
      );
      await repository.createOrder(newOrder);
      
      emit(OrderPlacedSuccess(orderId));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onLoadMyOrdersRequested(LoadMyOrdersRequested event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      await repository.syncPendingOrders();
      final orders = await repository.getMyOrders();
      emit(MyOrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}