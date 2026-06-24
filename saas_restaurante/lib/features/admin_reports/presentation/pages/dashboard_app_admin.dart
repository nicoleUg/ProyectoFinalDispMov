import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../bloc/admin_reports_bloc.dart';
import '../bloc/admin_reports_event.dart';
import '../bloc/admin_reports_state.dart';
import '../../../admin_orders/presentation/bloc/admin_orders_bloc.dart';
import '../../../admin_orders/presentation/bloc/admin_orders_state.dart';
import '../widgets/admin_drawer.dart';

class DashboardAppAdmin extends StatefulWidget {
  const DashboardAppAdmin({super.key});

  @override
  State<DashboardAppAdmin> createState() => _DashboardAppAdminState();
}

class _DashboardAppAdminState extends State<DashboardAppAdmin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<AdminReportsBloc>().add(const LoadReportDataRequested(period: 'today'));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: RSColors.background,
      drawer: isDesktop
          ? null
          : const Drawer(
              child: AdminDrawer(activeRoute: '/admin-dashboard', isMobileDrawer: true),
            ),
      body: Row(
        children: [
          if (isDesktop)
            const AdminDrawer(activeRoute: '/admin-dashboard', isMobileDrawer: false),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(RSSpacing.lg),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryCards(),
                            RSSpacing.verticalLg,
                            _buildGridContent(isDesktop),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!isDesktop)
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  );
                },
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard General',
                  style: RSTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Bienvenido al panel administrativo de Restaurante SaaS.',
                  style: RSTypography.bodyMedium.copyWith(
                    color: RSColors.textOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<AdminReportsBloc, AdminReportsState>(
      builder: (context, state) {
        double earnings = 0.0;
        int orders = 0;

        if (state is AdminReportsLoaded) {
          earnings = state.reportData.totalEarnings;
          orders = state.reportData.totalOrders;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 32) / 3;
            final isTooNarrow = constraints.maxWidth < 600;

            final children = [
              _buildStatCard(
                'Ingresos de Hoy',
                'Bs. ${earnings.toStringAsFixed(2)}',
                Icons.monetization_on,
                const Color(0xFF1B5E20),
                isTooNarrow ? double.infinity : cardWidth,
              ),
              _buildStatCard(
                'Órdenes de Hoy',
                '$orders',
                Icons.shopping_bag,
                const Color(0xFF0D47A1),
                isTooNarrow ? double.infinity : cardWidth,
              ),
              _buildStatCard(
                'Ticket Promedio',
                'Bs. ${orders > 0 ? (earnings / orders).toStringAsFixed(2) : "0.00"}',
                Icons.analytics,
                const Color(0xFFE65100),
                isTooNarrow ? double.infinity : cardWidth,
              ),
            ];

            if (isTooNarrow) {
              return Column(
                children: children.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: c,
                )).toList(),
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: children,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, double width) {
    return SizedBox(
      width: width,
      child: RSCard(
        padding: const EdgeInsets.all(RSSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: RSTypography.labelMedium.copyWith(color: RSColors.textOnSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: RSTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridContent(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Column(
            children: [
              _buildKitchenCapacityCard(),
              const SizedBox(height: 16),
              _buildQuickAccessCard(),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildKitchenCapacityCard()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildQuickAccessCard()),
            ],
          );
        }
      },
    );
  }

  Widget _buildKitchenCapacityCard() {
    return RSCard(
      padding: const EdgeInsets.all(RSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de Cocina Real-Time',
            style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            'Carga de trabajo actual en cocina.',
            style: RSTypography.bodyMedium.copyWith(color: RSColors.textOnSurfaceVariant),
          ),
          const Divider(height: 24),
          BlocBuilder<AdminOrdersBloc, AdminOrdersState>(
            builder: (context, state) {
              int pending = 0;
              int preparing = 0;
              int ready = 0;

              if (state is AdminOrdersLoaded) {
                pending = state.orders.where((o) => o.status == 'pending').length;
                preparing = state.orders.where((o) => o.status == 'preparing').length;
                ready = state.orders.where((o) => o.status == 'ready').length;
              }

              final total = pending + preparing + ready;

              return Column(
                children: [
                  _buildCapacityIndicator('Pendiente', pending, total, const Color(0xFFE65100)),
                  const SizedBox(height: 16),
                  _buildCapacityIndicator('En Preparación', preparing, total, const Color(0xFF0D47A1)),
                  const SizedBox(height: 16),
                  _buildCapacityIndicator('Listo para Entregar', ready, total, const Color(0xFF1B5E20)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pedidos Activos: $total',
                        style: RSTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      RSButton.tonal(
                        label: 'Gestionar Cocina',
                        size: RSButtonSize.small,
                        onPressed: () => context.go('/admin-orders'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityIndicator(String label, int count, int total, Color color) {
    final percent = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: RSTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            Text(
              '$count pedidos (${(percent * 100).toStringAsFixed(0)}%)',
              style: RSTypography.labelLarge.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard() {
    return RSCard(
      padding: const EdgeInsets.all(RSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accesos Rápidos',
            style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildShortcutButton(
            'Editor de Menú',
            'Modificar platos, precios y disponibilidad.',
            Icons.restaurant_menu,
            RSColors.primary,
            () => context.go('/admin-menu'),
          ),
          const SizedBox(height: 12),
          _buildShortcutButton(
            'Tablero de Ventas',
            'Ver reportes gráficos detallados de ingresos.',
            Icons.bar_chart,
            const Color(0xFF1B5E20),
            () => context.go('/admin-reports'),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: RSColors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: RSTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    subtitle,
                    style: RSTypography.labelSmall.copyWith(color: RSColors.textOnSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: RSColors.textOnSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: RSColors.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go('/admin-menu');
          if (index == 2) context.go('/admin-orders');
        },
        selectedItemColor: RSColors.primary,
        unselectedItemColor: RSColors.textOnSurfaceVariant,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
