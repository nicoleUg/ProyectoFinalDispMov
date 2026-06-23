import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_event.dart';
import 'menu_state.dart';
import '../../data/repositories/menu_repository.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository menuRepository;

  MenuBloc({
    required this.menuRepository,
  }) : super(MenuInitial()) {
    on<LoadMenuRequested>(_onLoadMenuRequested);
    on<CategorySelected>(_onCategorySelected);
  }

  Future<void> _onLoadMenuRequested(LoadMenuRequested event, Emitter<MenuState> emit) async {
    emit(MenuLoading());

    try {
      final categories = await menuRepository.getCategories();
      
      if (categories.isEmpty) {
        emit(const MenuLoaded(
          categories: [],
          products: [],
          selectedCategoryId: '',
        ));
        return;
      }

      final firstCategoryId = categories.first.id;
      final products = await menuRepository.getProductsByCategory(firstCategoryId);

      emit(MenuLoaded(
        categories: categories,
        products: products,
        selectedCategoryId: firstCategoryId,
      ));
    } catch (e) {
      emit(const MenuError('No se pudo cargar el menú'));
    }
  }

  Future<void> _onCategorySelected(CategorySelected event, Emitter<MenuState> emit) async {
    final currentState = state;
    if (currentState is MenuLoaded) {
      emit(MenuLoading());
      try {
        final products = await menuRepository.getProductsByCategory(event.categoryId);
        emit(MenuLoaded(
          categories: currentState.categories,
          products: products,
          selectedCategoryId: event.categoryId,
        ));
      } catch (e) {
        emit(const MenuError('No se pudieron cargar los productos'));
      }
    }
  }
}