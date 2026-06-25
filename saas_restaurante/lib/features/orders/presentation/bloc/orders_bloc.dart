import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart'; 
import 'orders_event.dart';
import 'orders_state.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../../Core/secure_storage/secure_storage_service.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository repository;
  final SecureStorageService secureStorage;

  OrdersBloc(this.repository, this.secureStorage) : super(OrdersInitial()) {
    on<ConfirmOrderRequested>(_onConfirmOrderRequested);
    on<LoadMyOrdersRequested>(_onLoadMyOrdersRequested);
  }

  Future<void> _onConfirmOrderRequested(ConfirmOrderRequested event, Emitter<OrdersState> emit) async {
    if (state is OrdersLoading) return; // Evitar confirmaciones duplicadas por doble toque rápido.
    emit(OrdersLoading());
    try {
      final orderId = const Uuid().v4();
      final tableId = await secureStorage.getTableId();
      final tableNumber = int.tryParse(tableId ?? '0') ?? 0;

      print('[OrdersBloc] Confirmando pedido de mesa. tableId recuperado: "$tableId", tableNumber: $tableNumber');

      final token = await secureStorage.getAccessToken();
      String? userId;
      if (token != null) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            final normalized = base64Url.normalize(payload);
            final decodedStr = utf8.decode(base64Url.decode(normalized));
            final decodedJson = json.decode(decodedStr);
            userId = decodedJson['sub']?.toString();
          }
        } catch (_) {}
      }

      final orderItems = event.cartItems.map((c) => OrderItemEntity(
        productName: c.name,
        quantity: c.quantity,
      )).toList();
      final newOrder = OrderEntity(
        id: orderId,
        total: event.total,
        status: 'pending', 
        createdAt: DateTime.now(),
        items: orderItems,
        tableNumber: tableNumber,
        userId: userId,
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