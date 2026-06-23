import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';
import 'admin_menu_event.dart';
import 'admin_menu_state.dart';

class AdminMenuBloc extends Bloc<AdminMenuEvent, AdminMenuState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final CreateProductUseCase createProductUseCase;

  AdminMenuBloc({
    required this.getCategoriesUseCase,
    required this.getProductsByCategoryUseCase,
    required this.createCategoryUseCase,
    required this.createProductUseCase,
  }) : super(AdminMenuInitial()) {
    on<LoadAdminMenuRequested>(_onLoadAdminMenuRequested);
    on<AddCategoryRequested>(_onAddCategoryRequested);
    on<AddProductRequested>(_onAddProductRequested);
    on<UpdateProductRequested>(_onUpdateProductRequested);
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
      // Simulado debido a falta de endpoint de edición en el backend
      await Future.delayed(const Duration(milliseconds: 800));
      emit(const AdminMenuActionSuccess('Producto actualizado exitosamente (Simulado)'));
    } catch (e) {
      emit(AdminMenuError('Error al actualizar producto: $e'));
    }
  }
}
