import 'package:equatable/equatable.dart';
import '../../../menu/domain/entities/category_entity.dart';
import '../../../menu/domain/entities/product_entity.dart';

abstract class AdminMenuState extends Equatable {
  const AdminMenuState();

  @override
  List<Object?> get props => [];
}

class AdminMenuInitial extends AdminMenuState {}

class AdminMenuLoading extends AdminMenuState {}

class AdminMenuLoaded extends AdminMenuState {
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final String? selectedCategoryId;

  const AdminMenuLoaded({
    required this.categories,
    required this.products,
    this.selectedCategoryId,
  });

  @override
  List<Object?> get props => [categories, products, selectedCategoryId];
}

class AdminMenuActionSuccess extends AdminMenuState {
  final String message;

  const AdminMenuActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminMenuError extends AdminMenuState {
  final String error;

  const AdminMenuError(this.error);

  @override
  List<Object?> get props => [error];
}
