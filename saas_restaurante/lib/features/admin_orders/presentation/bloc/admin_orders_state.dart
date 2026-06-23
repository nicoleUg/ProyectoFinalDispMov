import 'package:equatable/equatable.dart';
import '../../../orders/domain/entities/order_entity.dart';

abstract class AdminOrdersState extends Equatable {
  const AdminOrdersState();

  @override
  List<Object?> get props => [];
}

class AdminOrdersInitial extends AdminOrdersState {}

class AdminOrdersLoading extends AdminOrdersState {}

class AdminOrdersLoaded extends AdminOrdersState {
  final List<OrderEntity> orders;

  const AdminOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class AdminOrdersError extends AdminOrdersState {
  final String error;

  const AdminOrdersError(this.error);

  @override
  List<Object?> get props => [error];
}
