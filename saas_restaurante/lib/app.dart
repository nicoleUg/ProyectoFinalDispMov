import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Core/injection_container.dart' as di;
import 'Core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/menu/presentation/blocs/menu_bloc.dart';
import 'features/admin_menu/presentation/bloc/admin_menu_bloc.dart';
import 'features/admin_orders/presentation/bloc/admin_orders_bloc.dart';
import 'features/admin_orders/presentation/bloc/admin_orders_event.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthRequested()),
        ),
        BlocProvider<CartCubit>(
          create: (context) => di.sl<CartCubit>()..loadCart(),
        ),
        BlocProvider<MenuBloc>(
          create: (context) => di.sl<MenuBloc>(),
        ),
        BlocProvider<AdminMenuBloc>(
          create: (context) => di.sl<AdminMenuBloc>(),
        ),
        BlocProvider<AdminOrdersBloc>(
          create: (context) => di.sl<AdminOrdersBloc>()..add(LoadAdminOrdersRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Restaurante SaaS',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFFB02F00),
          useMaterial3: true,
        ),
      ),
    );
  }
}