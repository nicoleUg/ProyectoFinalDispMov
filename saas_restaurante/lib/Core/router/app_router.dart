import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/main_layout.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/register_page.dart';
import '../../../features/menu/presentation/pages/menu_page.dart';
import '../../../features/cart/presentation/pages/cart_page.dart';
import '../../../features/orders/presentation/pages/order_tracking_page.dart';
import '../../../features/admin_menu/presentation/pages/gesti_n_de_men_app_admin.dart';

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