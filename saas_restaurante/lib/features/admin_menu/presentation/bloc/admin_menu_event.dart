import 'package:equatable/equatable.dart';

abstract class AdminMenuEvent extends Equatable {
  const AdminMenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminMenuRequested extends AdminMenuEvent {
  final String? selectedCategoryId;
  
  const LoadAdminMenuRequested({this.selectedCategoryId});
  
  @override
  List<Object?> get props => [selectedCategoryId];
}

class AdminCategorySelected extends AdminMenuEvent {
  final String categoryId;
  
  const AdminCategorySelected(this.categoryId);
  
  @override
  List<Object?> get props => [categoryId];
}

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

class UpdateProductRequested extends AdminMenuEvent {
  final String productId;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String? localImagePath;
  final bool isAvailable;

  const UpdateProductRequested({
    required this.productId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.localImagePath,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [productId, categoryId, name, description, price, localImagePath, isAvailable];
}

class DeleteProductRequested extends AdminMenuEvent {
  final String productId;

  const DeleteProductRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}