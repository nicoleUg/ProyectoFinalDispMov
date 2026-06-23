import 'package:equatable/equatable.dart';

abstract class AdminOrdersEvent extends Equatable {
  const AdminOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminOrdersRequested extends AdminOrdersEvent {}

class UpdateOrderStatusRequested extends AdminOrdersEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatusRequested({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderId, newStatus];
}
