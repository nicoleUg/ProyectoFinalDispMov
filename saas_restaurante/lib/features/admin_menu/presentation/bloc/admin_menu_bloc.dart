import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import 'admin_menu_event.dart';
import 'admin_menu_state.dart';

class AdminMenuBloc extends Bloc<AdminMenuEvent, AdminMenuState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  AdminMenuBloc({
    required this.getCategoriesUseCase,
    required this.getProductsByCategoryUseCase,
    required this.createCategoryUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(AdminMenuInitial()) {
    on<LoadAdminMenuRequested>(_onLoadAdminMenuRequested);
    on<AddCategoryRequested>(_onAddCategoryRequested);
    on<AddProductRequested>(_onAddProductRequested);
    on<UpdateProductRequested>(_onUpdateProductRequested);
    on<DeleteProductRequested>(_onDeleteProductRequested);
  }

  Future<void> _onLoadAdminMenuRequested(
    LoadAdminMenuRequested event,
    Emitter<AdminMenuState> emit,
  ) async {
    emit(AdminMenuLoading());
    try {
      final categories = await getCategoriesUseCase.call();
      if (categories.isEmpty) {
        emit(const AdminMenuLoaded(categories: [], products: []));
        return;
      }
      final firstCategoryId = categories.first.id;
      final products = await getProductsByCategoryUseCase.call(firstCategoryId);
      emit(AdminMenuLoaded(
        categories: categories,
        products: products,
        selectedCategoryId: firstCategoryId,
      ));
    } catch (e) {
      emit(AdminMenuError('Error al cargar datos del menú: $e'));
    }
  }

  Future<void> _onAddCategoryRequested(
    AddCategoryRequested event,
    Emitter<AdminMenuState> emit,
  ) async {
    emit(AdminMenuLoading());
    try {
      await createCategoryUseCase.call(
        name: event.name,
        orderIndex: event.orderIndex,
        localImagePath: event.localImagePath,
      );
      emit(const AdminMenuActionSuccess('Categoría creada exitosamente'));
    } catch (e) {
      emit(AdminMenuError('Error al crear categoría: $e'));
    }
  }

  Future<void> _onAddProductRequested(
    AddProductRequested event,
    Emitter<AdminMenuState> emit,
  ) async {
    emit(AdminMenuLoading());
    try {
      await createProductUseCase.call(
        categoryId: event.categoryId,
        name: event.name,
        description: event.description,
        price: event.price,
        localImagePath: event.localImagePath,
      );
      emit(const AdminMenuActionSuccess('Producto creado exitosamente'));
    } catch (e) {
      emit(AdminMenuError('Error al crear producto: $e'));
    }
  }

  Future<void> _onUpdateProductRequested(
    UpdateProductRequested event,
    Emitter<AdminMenuState> emit,
  ) async {
    emit(AdminMenuLoading());
    try {
      await updateProductUseCase.call(
        productId: event.productId,
        categoryId: event.categoryId,
        name: event.name,
        description: event.description,
        price: event.price,
        localImagePath: event.localImagePath,
        isAvailable: event.isAvailable,
      );
      emit(const AdminMenuActionSuccess('Producto actualizado exitosamente'));
    } catch (e) {
      emit(AdminMenuError('Error al actualizar producto: $e'));
    }
  }

  Future<void> _onDeleteProductRequested(
    DeleteProductRequested event,
    Emitter<AdminMenuState> emit,
  ) async {
    emit(AdminMenuLoading());
    try {
      await deleteProductUseCase.call(event.productId);
      emit(const AdminMenuActionSuccess('Producto eliminado exitosamente'));
    } catch (e) {
      emit(AdminMenuError('Error al eliminar producto: $e'));
    }
  }
}
