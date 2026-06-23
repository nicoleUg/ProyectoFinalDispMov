import 'package:equatable/equatable.dart';

abstract class AdminMenuEvent extends Equatable {
  const AdminMenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminMenuRequested extends AdminMenuEvent {}

class AddCategoryRequested extends AdminMenuEvent {
  final String name;
  final int orderIndex;
  final String? localImagePath;

  const AddCategoryRequested({
    required this.name,
    required this.orderIndex,
    required this.localImagePath,
  });

  @override
  List<Object?> get props => [name, orderIndex, localImagePath];
}

class AddProductRequested extends AdminMenuEvent {
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String? localImagePath;

  const AddProductRequested({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.localImagePath,
  });

  @override
  List<Object?> get props => [categoryId, name, description, price, localImagePath];
}
