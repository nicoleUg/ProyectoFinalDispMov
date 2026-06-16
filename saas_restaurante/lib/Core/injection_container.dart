import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'database/app_database.dart';
import 'secure_storage/secure_storage_service.dart';
import 'network/api_client.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/menu/data/datasource/menu_local_datasource.dart';
import '../../features/menu/data/datasource/menu_remote_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/domain/usecases/get_local_categories_usecase.dart';
import '../../features/menu/domain/usecases/get_local_products_usecase.dart';
import '../../features/menu/domain/usecases/sync_menu_usecase.dart';
import '../../features/menu/presentation/bloc/menu_bloc.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/data/datasource/orders_local_datasource.dart';
import '../../features/orders/data/datasource/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';
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
        getCategories: sl(),
        getProducts: sl(),
        syncMenu: sl(),
      ));

  sl.registerLazySingleton(() => GetLocalCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetLocalProductsUseCase(sl()));
  sl.registerLazySingleton(() => SyncMenuUseCase(sl()));

  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(localDataSource: sl(), remoteDataSource: sl())
  );

  sl.registerLazySingleton<MenuRemoteDataSource>(() => MenuRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<MenuLocalDataSource>(() => MenuLocalDataSourceImpl(sl()));
  sl.registerFactory(() => CartCubit(
    addToCartUseCase: sl(),
    getCartItemsUseCase: sl(),
    updateQuantityUseCase: sl(),
  ));

  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuantityUseCase(sl())); 

  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));
  sl.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSourceImpl(sl()));
  sl.registerFactory(() => OrdersBloc(sl()));
  
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(localDataSource: sl(), remoteDataSource: sl())
  );
  
  sl.registerLazySingleton<OrdersLocalDataSource>(() => OrdersLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<OrdersRemoteDataSource>(() => OrdersRemoteDataSourceImpl(sl()));
}