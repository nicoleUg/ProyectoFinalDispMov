import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../bloc/admin_orders_bloc.dart';
import '../bloc/admin_orders_event.dart';
import '../bloc/admin_orders_state.dart';
import '../../../orders/domain/entities/order_entity.dart';

class PedidosAppAdmin extends StatefulWidget {
  const PedidosAppAdmin({super.key});

  @override
  State<PedidosAppAdmin> createState() => _PedidosAppAdminState();
}

class _PedidosAppAdminState extends State<PedidosAppAdmin> {
  @override
  void initState() {
    super.initState();
    // Load orders on page init
    context.read<AdminOrdersBloc>().add(LoadAdminOrdersRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: RSColors.background,
      body: Row(
        children: [
          if (isDesktop) _buildDesktopDrawer(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isDesktop),
                Expanded(
                  child: BlocConsumer<AdminOrdersBloc, AdminOrdersState>(
                    listener: (context, state) {
                      if (state is AdminOrdersError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: RSColors.error,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminOrdersLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: RSColors.primary),
                        );
                      }

                      if (state is AdminOrdersLoaded) {
                        return _buildKanbanContent(state.orders, isDesktop);
                      }

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error al cargar el panel de cocina',
                              style: RSTypography.bodyLarge,
                            ),
                            RSSpacing.verticalMd,
                            RSButton.filled(
                              label: 'Reintentar',
                              onPressed: () {
                                context.read<AdminOrdersBloc>().add(LoadAdminOrdersRequested());
                              },
                            ),
                          ],
                        ),
                      );
                    },
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

  Widget _buildDesktopDrawer() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: RSColors.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restaurante SaaS',
                  style: RSTypography.titleLarge.copyWith(
                    color: RSColors.primary,
                  ),
                ),
                RSSpacing.verticalMd,
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: RSColors.outlineVariant.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.store, color: RSColors.textOnSurfaceVariant),
                    ),
                    RSSpacing.horizontalSm,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store #104 - Cocina',
                          style: RSTypography.titleSmall.copyWith(
                            color: RSColors.textOnSurfaceVariant,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: RSColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            RSSpacing.horizontalSm,
                            Text(
                              'Online',
                              style: RSTypography.labelSmall.copyWith(
                                color: RSColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(Icons.dashboard_outlined, 'Dashboard', false, () => context.go('/admin-dashboard')),
          _buildDrawerItem(Icons.restaurant_menu, 'Menu Editor', false, () => context.go('/admin-menu')),
          _buildDrawerItem(Icons.receipt_long, 'Kitchen Board', true, () {}),
          _buildDrawerItem(Icons.bar_chart, 'Reports', false, () => context.go('/admin-reports')),
          _buildDrawerItem(Icons.settings_outlined, 'Settings', false, () {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'v1.0.0-SaaS',
              style: RSTypography.labelSmall.copyWith(
                color: RSColors.textOnSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? RSColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? RSColors.primary : RSColors.textOnSurfaceVariant,
        ),
        title: Text(
          title,
          style: RSTypography.titleSmall.copyWith(
            color: isActive ? RSColors.primary : RSColors.textOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
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
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {}, // Can be integrated with a scaffold scaffold drawer later
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kitchen Kanban',
                  style: RSTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Drag and drop orders to update kitchen status in real time.',
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

  Widget _buildKanbanContent(List<OrderEntity> orders, bool isDesktop) {
    final pendingOrders = orders.where((o) => o.status == 'pending').toList();
    final preparingOrders = orders.where((o) => o.status == 'preparing').toList();
    final readyOrders = orders.where((o) => o.status == 'ready').toList();

    if (isDesktop) {
      // Desktop View: Side by Side Column Layout
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: RSOrderKanbanColumn(
                title: 'Pendiente',
                accentColor: const Color(0xFFE65100), // Amber Accent
                onOrderDropped: (orderId) => _handleOrderDrop(orderId, 'pending'),
                children: pendingOrders.map((o) => _buildOrderCard(o)).toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RSOrderKanbanColumn(
                title: 'En Preparación',
                accentColor: const Color(0xFF0D47A1), // Blue Accent
                onOrderDropped: (orderId) => _handleOrderDrop(orderId, 'preparing'),
                children: preparingOrders.map((o) => _buildOrderCard(o)).toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RSOrderKanbanColumn(
                title: 'Listo',
                accentColor: const Color(0xFF1B5E20), // Green Accent
                onOrderDropped: (orderId) => _handleOrderDrop(orderId, 'ready'),
                children: readyOrders.map((o) => _buildOrderCard(o)).toList(),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile View: Tab Bar Layout
      return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: RSColors.primary,
              unselectedLabelColor: RSColors.textOnSurfaceVariant,
              indicatorColor: RSColors.primary,
              indicatorWeight: 3.0,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pendiente'),
                      const SizedBox(width: 4),
                      _buildCountBadge(pendingOrders.length, const Color(0xFFE65100)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Cocina'),
                      const SizedBox(width: 4),
                      _buildCountBadge(preparingOrders.length, const Color(0xFF0D47A1)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Listo'),
                      const SizedBox(width: 4),
                      _buildCountBadge(readyOrders.length, const Color(0xFF1B5E20)),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  RSOrderKanbanColumn(
                    title: 'Órdenes Pendientes',
                    accentColor: const Color(0xFFE65100),
                    onOrderDropped: (orderId) => _handleOrderDrop(orderId, 'pending'),
                    children: pendingOrders.map((o) => _buildOrderCard(o)).toList(),
                  ),
                  RSOrderKanbanColumn(
                    title: 'En Preparación',
                    accentColor: const Color(0xFF0D47A1),
                    onOrderDropped: (orderId) => _handleOrderDrop(orderId, 'preparing'),
                    children: preparingOrders.map((o) => _buildOrderCard(o)).toList(),
                  ),
                  RSOrderKanbanColumn(
                    title: 'Listos para Entrega',
                    accentColor: const Color(0xFF1B5E20),
                    onOrderDropped: (orderId) => _handleOrderDrop(orderId, 'ready'),
                    children: readyOrders.map((o) => _buildOrderCard(o)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCountBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    final difference = DateTime.now().difference(order.createdAt);
    final minutesAgo = difference.inMinutes;

    return RSDraggableOrderCard(
      orderId: order.id,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Mesa #${order.id.substring(order.id.length - 3).toUpperCase()}',
                    style: RSTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (order.status == 'ready') ...[
                    const SizedBox(width: 8),
                    const PulseIndicator(color: Color(0xFF1B5E20)),
                  ] else if (minutesAgo > 20) ...[
                    const SizedBox(width: 8),
                    const PulseIndicator(color: RSColors.error),
                  ],
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 12, color: RSColors.textOnSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    minutesAgo <= 0 ? 'Ahora' : 'Hace $minutesAgo min',
                    style: RSTypography.labelSmall.copyWith(
                      color: minutesAgo > 20 ? RSColors.error : RSColors.textOnSurfaceVariant,
                      fontWeight: minutesAgo > 20 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          // List of items
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${order.total.toStringAsFixed(2)}',
                style: RSTypography.titleSmall.copyWith(
                  color: RSColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildActionButton(order),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(OrderEntity order) {
    if (order.status == 'pending') {
      return RSButton.tonal(
        label: 'Cocinar',
        size: RSButtonSize.small,
        icon: const Icon(Icons.play_arrow, size: 14),
        onPressed: () {
          context.read<AdminOrdersBloc>().add(UpdateOrderStatusRequested(
                orderId: order.id,
                newStatus: 'preparing',
              ));
          _showStatusUpdateFeedback(order.id, 'preparing');
        },
      );
    } else if (order.status == 'preparing') {
      return RSButton.filled(
        label: 'Terminar',
        size: RSButtonSize.small,
        icon: const Icon(Icons.check, size: 14),
        onPressed: () {
          context.read<AdminOrdersBloc>().add(UpdateOrderStatusRequested(
                orderId: order.id,
                newStatus: 'ready',
              ));
          _showStatusUpdateFeedback(order.id, 'ready');
        },
      );
    } else {
      return RSButton.filled(
        label: 'Entregar',
        size: RSButtonSize.small,
        icon: const Icon(Icons.local_shipping, size: 14),
        onPressed: () {
          context.read<AdminOrdersBloc>().add(UpdateOrderStatusRequested(
                orderId: order.id,
                newStatus: 'delivered', // Move out of board
              ));
          _showStatusUpdateFeedback(order.id, 'delivered');
        },
      );
    }
  }

  void _handleOrderDrop(String orderId, String targetStatus) {
    context.read<AdminOrdersBloc>().add(UpdateOrderStatusRequested(
          orderId: orderId,
          newStatus: targetStatus,
        ));
    _showStatusUpdateFeedback(orderId, targetStatus);
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
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/admin-dashboard');
          if (index == 1) context.go('/admin-menu');
        },
        selectedItemColor: RSColors.primary,
        unselectedItemColor: RSColors.textOnSurfaceVariant,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            activeIcon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateFeedback(String orderId, String status) {
    final statusLabel = status == 'pending' 
        ? 'Pendientes' 
        : status == 'preparing' 
            ? 'En Preparación' 
            : status == 'ready' 
                ? 'Listos' 
                : 'Entregados';

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text('Pedido #${orderId.substring(orderId.length - 3).toUpperCase()} movido a $statusLabel'),
          ],
        ),
        backgroundColor: status == 'ready' 
            ? const Color(0xFF1B5E20) 
            : status == 'preparing' 
                ? const Color(0xFF0D47A1) 
                : Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class PulseIndicator extends StatefulWidget {
  final Color color;
  const PulseIndicator({super.key, required this.color});

  @override
  State<PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.5),
              blurRadius: 4,
              spreadRadius: 2,
            )
          ]
        ),
      ),
    );
  }
}
