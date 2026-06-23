import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/main_layout.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/register_page.dart';
import '../../../features/menu/presentation/pages/menu_page.dart';
import '../../../features/cart/presentation/pages/cart_page.dart';
import '../../../features/orders/presentation/pages/order_tracking_page.dart';
import '../../../features/admin_menu/presentation/pages/gesti_n_de_men_app_admin.dart';
import '../../../features/admin_menu/presentation/pages/nuevo_producto_app_admin.dart';
import '../../../features/admin_menu/presentation/pages/editar_producto_app_admin.dart';
import '../../../features/menu/domain/entities/product_entity.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/admin-menu',
        builder: (context, state) => const GestiNDeMenAppAdmin(),
        routes: [
          GoRoute(
            path: 'new-product',
            builder: (context, state) => const NuevoProductoAppAdmin(),
          ),
          GoRoute(
            path: 'edit-product',
            builder: (context, state) {
              final product = state.extra as ProductEntity;
              return EditarProductoAppAdmin(product: product);
            },
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const MenuPage(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrderTrackingPage(),
          ),
        ],
      ),
    ],
  );
}