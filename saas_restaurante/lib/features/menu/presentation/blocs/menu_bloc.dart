import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_event.dart';
import 'menu_state.dart';
import '../../domain/usecases/get_local_categories_usecase.dart';
import '../../domain/usecases/get_local_products_usecase.dart';
import '../../domain/usecases/sync_menu_usecase.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetLocalCategoriesUseCase getCategories;
  final GetLocalProductsUseCase getProducts;
  final SyncMenuUseCase syncMenu;

  MenuBloc({
    required this.getCategories,
    required this.getProducts,
    required this.syncMenu,
  }) : super(MenuLoading()) {
    on<LoadMenuRequested>(_onLoadMenuRequested);
    on<CategorySelected>(_onCategorySelected);
  }

  Future<void> _onLoadMenuRequested(LoadMenuRequested event, Emitter<MenuState> emit) async {
    emit(MenuLoading());

    try {
      syncMenu.call().then((_) {
      });

      final categories = await getCategories.call();
      
      if (categories.isEmpty) {
        emit(const MenuError('El menú no está disponible en este momento.'));
        return;
      }

      final firstCategoryId = categories.first.id;
      final products = await getProducts.call(firstCategoryId);

      emit(MenuLoaded(
        categories: categories,
        products: products,
        selectedCategoryId: firstCategoryId,
      ));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> _onCategorySelected(CategorySelected event, Emitter<MenuState> emit) async {
    final currentState = state;
    if (currentState is MenuLoaded) {
      final products = await getProducts.call(event.categoryId);
      emit(MenuLoaded(
        categories: currentState.categories,
        products: products,
        selectedCategoryId: event.categoryId,
      ));
    }
  }
}