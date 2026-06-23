import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_admin_orders_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import 'admin_orders_event.dart';
import 'admin_orders_state.dart';

class AdminOrdersBloc extends Bloc<AdminOrdersEvent, AdminOrdersState> {
  final GetAdminOrdersUseCase getAdminOrdersUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  AdminOrdersBloc({
    required this.getAdminOrdersUseCase,
    required this.updateOrderStatusUseCase,
  }) : super(AdminOrdersInitial()) {
    on<LoadAdminOrdersRequested>(_onLoadAdminOrdersRequested);
    on<UpdateOrderStatusRequested>(_onUpdateOrderStatusRequested);
  }

  Future<void> _onLoadAdminOrdersRequested(
    LoadAdminOrdersRequested event,
    Emitter<AdminOrdersState> emit,
  ) async {
    emit(AdminOrdersLoading());
    try {
      final orders = await getAdminOrdersUseCase.call();
      emit(AdminOrdersLoaded(orders));
    } catch (e) {
      emit(AdminOrdersError('Error al cargar pedidos: $e'));
    }
  }

  Future<void> _onUpdateOrderStatusRequested(
    UpdateOrderStatusRequested event,
    Emitter<AdminOrdersState> emit,
  ) async {
    // Note: We can temporarily show loading or directly optimistically update
    // But since it's a local database operation, it is extremely fast.
    try {
      await updateOrderStatusUseCase.call(
        orderId: event.orderId,
        newStatus: event.newStatus,
      );
      // Reload orders to reflect changes
      final orders = await getAdminOrdersUseCase.call();
      emit(AdminOrdersLoaded(orders));
    } catch (e) {
      emit(AdminOrdersError('Error al actualizar estado del pedido: $e'));
    }
  }
}
