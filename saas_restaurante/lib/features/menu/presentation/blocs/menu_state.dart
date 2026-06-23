import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

abstract class MenuState extends Equatable {
  const MenuState();
  
  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final String selectedCategoryId;

  const MenuLoaded({
    required this.categories,
    required this.products,
    required this.selectedCategoryId,
  });

  @override
  List<Object?> get props => [categories, products, selectedCategoryId];
}

class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}