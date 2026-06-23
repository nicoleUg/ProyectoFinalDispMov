import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'database/app_database.dart';
import 'secure_storage/secure_storage_service.dart';
import 'network/api_client.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/menu/data/repositories/menu_repository.dart';
import '../../features/menu/presentation/blocs/menu_bloc.dart';
import '../../features/admin_menu/presentation/bloc/admin_menu_bloc.dart';
import '../../features/admin_menu/domain/repositories/admin_menu_repository.dart';
import '../../features/admin_menu/data/repositories/admin_menu_repository_impl.dart';
import '../../features/admin_menu/domain/usecases/get_categories_usecase.dart';
import '../../features/admin_menu/domain/usecases/get_products_by_category_usecase.dart';
import '../../features/admin_menu/domain/usecases/create_category_usecase.dart';
import '../../features/admin_menu/domain/usecases/create_product_usecase.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/data/datasources/orders_local_datasource.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';
import '../../features/admin_orders/presentation/bloc/admin_orders_bloc.dart';
import '../../features/admin_orders/domain/repositories/admin_orders_repository.dart';
import '../../features/admin_orders/data/repositories/admin_orders_repository_impl.dart';
import '../../features/admin_orders/domain/usecases/get_admin_orders_usecase.dart';
import '../../features/admin_orders/domain/usecases/update_order_status_usecase.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/domain/usescases/add_to_cart_usecase.dart';
import '../../features/cart/domain/usescases/get_cart_items_usecase.dart';
import '../../features/cart/domain/usescases/update_cart_quantity_usecase.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
final sl = GetIt.instance; 

Future<void> init() async {
  
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => AppDatabase());

  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => sl<ApiClient>().dio); 

  sl.registerFactory(() => AuthBloc(
        authRepository: sl(),
      ));

  sl.registerLazySingleton(() => AuthRepository(sl(), sl()));

  sl.registerFactory(() => MenuBloc(
        menuRepository: sl(),
      ));

  sl.registerFactory(() => AdminMenuBloc(
        getCategoriesUseCase: sl(),
        getProductsByCategoryUseCase: sl(),
        createCategoryUseCase: sl(),
        createProductUseCase: sl(),
      ));

  // Admin Menu
  sl.registerLazySingleton<AdminMenuRepository>(() => AdminMenuRepositoryImpl(menuRepository: sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => CreateProductUseCase(sl()));

  sl.registerFactory(() => AdminOrdersBloc(
        getAdminOrdersUseCase: sl(),
        updateOrderStatusUseCase: sl(),
      ));

  // Admin Orders
  sl.registerLazySingleton<AdminOrdersRepository>(() => AdminOrdersRepositoryImpl(db: sl()));
  sl.registerLazySingleton(() => GetAdminOrdersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));

  sl.registerLazySingleton(() => MenuRepository(sl()));
  sl.registerFactory(() => CartCubit(
    addToCartUseCase: sl(),
    getCartItemsUseCase: sl(),
    updateQuantityUseCase: sl(),
  ));

  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartQuantityUseCase(sl())); 

  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));
  sl.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSourceImpl(sl()));
  sl.registerFactory(() => OrdersBloc(sl()));
  
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(localDataSource: sl(), remoteDataSource: sl())
  );
  
  sl.registerLazySingleton<OrdersLocalDataSource>(() => OrdersLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<OrdersRemoteDataSource>(() => OrdersRemoteDataSourceImpl(sl()));
}