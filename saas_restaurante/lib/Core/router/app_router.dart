import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/main_layout.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/register_page.dart';
import '../../../features/menu/presentation/pages/menu_page.dart';
import '../../../features/menu/presentation/pages/product_detail_page.dart';
import '../../../features/cart/presentation/pages/cart_page.dart';
import '../../../features/orders/presentation/pages/order_tracking_page.dart';
import '../../../features/admin_menu/presentation/pages/gesti_n_de_men_app_admin.dart';
import '../../../features/admin_menu/presentation/pages/nuevo_producto_app_admin.dart';
import '../../../features/admin_menu/presentation/pages/editar_producto_app_admin.dart';
import '../../../features/menu/domain/entities/product_entity.dart';
import '../../../features/admin_orders/presentation/pages/pedidos_app_admin.dart';
import '../../../features/admin_reports/presentation/pages/dashboard_app_admin.dart';
import '../../../features/admin_reports/presentation/pages/reporte_de_ventas_app_admin.dart';
import '../../../features/deeplinking/presentation/pages/table_handler_page.dart';
import '../../../features/table_scanner/presentation/pages/qr_scanner_page.dart';

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
        path: '/admin-dashboard',
        builder: (context, state) => const DashboardAppAdmin(),
      ),
      GoRoute(
        path: '/admin-reports',
        builder: (context, state) => const ReporteDeVentasAppAdmin(),
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
      GoRoute(
        path: '/admin-orders',
        builder: (context, state) => const PedidosAppAdmin(),
      ),
      // ─── Deeplink Routes ───────────────────────────────────────────────────
      GoRoute(
        path: '/table/:tableId',
        builder: (context, state) {
          final tableId = state.pathParameters['tableId'] ?? '0';
          return TableHandlerPage(tableId: tableId);
        },
      ),
      GoRoute(
        path: '/product/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId'] ?? '';
          return ProductDetailPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/orders/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'];
          return OrderTrackingPage(orderId: orderId);
        },
      ),
      // ─── Table Scanner Route ─────────────────────────────────────────────
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const QrScannerPage(),
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