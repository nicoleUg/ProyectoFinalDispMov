import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../../../../Core/layout/main_layout.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../../domain/entities/order_entity.dart';
import '../../../reviews/presentation/widgets/rating_dialog.dart';

class OrderTrackingPage extends StatefulWidget {
  /// When provided (via deeplink `restaurantesaas://orders/:orderId`),
  /// only the matching order will be shown. Otherwise shows the first active order.
  final String? orderId;
  const OrderTrackingPage({super.key, this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final primary = RSColors.primary;
  final background = RSColors.background;

  bool get _isDeeplinkMode => widget.orderId != null && widget.orderId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(LoadMyOrdersRequested());
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: _isDeeplinkMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/');
                  }
                },
              )
            : (isWideScreen
                ? null
                : Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          MainLayoutScope.of(context)?.scaffoldKey.currentState?.openDrawer();
                        },
                      );
                    },
                  )),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seguimiento de Pedido',
              style: RSTypography.titleMedium.copyWith(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isDeeplinkMode)
              Text(
                'ID: ${widget.orderId}',
                style: RSTypography.labelSmall.copyWith(
                  color: RSColors.textOnSurfaceVariant,
                ),
              ),
          ],
        ),
        // Badge when opened via deeplink
        actions: _isDeeplinkMode
            ? [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: RSColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RSColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link_rounded, size: 14, color: RSColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Deeplink',
                        style: RSTypography.labelSmall.copyWith(
                          color: RSColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          if (state is OrdersError) {
            return _buildError(state.message);
          }

          if (state is MyOrdersLoaded) {
            if (state.orders.isEmpty) {
              return _buildEmpty();
            }

            // ── Filter by orderId when in deeplink mode ──────────────────────
            OrderEntity? targetOrder;
            if (_isDeeplinkMode) {
              try {
                targetOrder = state.orders.firstWhere(
                  (o) => o.id == widget.orderId,
                );
              } catch (_) {
                return _buildNotFoundOrder();
              }
            } else {
              targetOrder = state.orders.first;
            }

            return _buildOrderView(targetOrder);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ─────────────────────── Empty States ────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: RSColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined, size: 56, color: RSColors.textOnSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin pedidos activos',
            style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando hagas un pedido, podrás seguir\nsu estado aquí.',
            style: RSTypography.bodyMedium.copyWith(color: RSColors.textOnSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $message', style: RSTypography.bodyMedium),
          const SizedBox(height: 16),
          RSButton.tonal(
            label: 'Reintentar',
            onPressed: () => context.read<OrdersBloc>().add(LoadMyOrdersRequested()),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundOrder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: RSColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 56, color: RSColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Pedido no encontrado',
            style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No existe un pedido con el ID:\n${widget.orderId}',
            style: RSTypography.bodyMedium.copyWith(color: RSColors.textOnSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Main Order View ──────────────────────────────────

  Widget _buildOrderView(OrderEntity order) {
    final isPreparing = order.status == 'preparing';
    final isReady = order.status == 'ready';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              _buildStatusHero(order.status),
              const SizedBox(height: 24),
              _buildTimelineCard(isPreparing, isReady),
              const SizedBox(height: 24),
              _buildOrderSummary(order),
              if (_isDeeplinkMode) ...[
                const SizedBox(height: 16),
                _buildDeeplinkInfo(order),
              ],
              // ── Botón de calificación (sólo cuando el pedido está listo) ─
              if (isReady) ...[
                const SizedBox(height: 16),
                _buildRateCard(order),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRateCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 20),
              const SizedBox(width: 8),
              Text(
                '¿Cómo estuvo tu pedido?',
                style: RSTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6D4C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Califica los platos que recibiste.',
            style: RSTypography.bodySmall.copyWith(
              color: RSColors.textOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          // Un botón por cada item del pedido
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RSButton.tonal(
                  label: '⭐ Calificar: ${item.productName}',
                  onPressed: () => showRatingDialog(
                    context,
                    // El productId no está en OrderItemEntity, usamos el nombre como clave temporal
                    productId: item.productName.toLowerCase().replaceAll(' ', '_'),
                    productName: item.productName,
                  ),
                ),
              )),
        ],
      ),
    );
  }


  Widget _buildStatusHero(String status) {
    final isReady = status == 'ready';
    final isPreparing = status == 'preparing';

    String title = isReady
        ? '¡Pedido Listo!'
        : isPreparing
            ? 'En Preparación'
            : 'Pedido Recibido';

    String subtitle = isReady
        ? 'Tu pedido está listo para recoger.'
        : isPreparing
            ? 'El equipo está preparando tu pedido.'
            : 'Hemos recibido tu pedido correctamente.';

    Color statusColor = isReady
        ? const Color(0xFF1B5E20)
        : isPreparing
            ? const Color(0xFFE65100)
            : RSColors.primary;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor.withOpacity(0.8), statusColor],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _CirclePatternPainter()),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isReady ? Icons.check_circle_rounded : Icons.restaurant_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(bool isPreparing, bool isReady) {
    double progress = isReady ? 1.0 : (isPreparing ? 0.5 : 0.1);

    return RSCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado del Pedido',
            style: RSTypography.labelMedium.copyWith(
              color: RSColors.textOnSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 4, color: RSColors.surfaceContainerLow),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: RSColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNode(Icons.check_rounded, 'Recibido', true, isActive: !isPreparing && !isReady),
                  _buildNode(Icons.restaurant_rounded, 'Preparando', isPreparing || isReady, isActive: isPreparing),
                  _buildNode(Icons.done_all_rounded, 'Listo', isReady, isActive: isReady),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNode(IconData icon, String label, bool isCompleted, {bool isActive = false}) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? RSColors.primary : RSColors.surfaceContainerLow,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: RSColors.primary.withOpacity(0.4), width: 4)
                : null,
          ),
          child: Icon(
            icon,
            color: isCompleted || isActive ? Colors.white : RSColors.textOnSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: RSTypography.labelSmall.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? RSColors.primary : RSColors.textOnSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(OrderEntity order) {
    final shortId = order.id.length >= 6
        ? order.id.substring(0, 6).toUpperCase()
        : order.id.toUpperCase();

    return RSCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NÚMERO DE PEDIDO',
                    style: RSTypography.labelSmall.copyWith(
                      color: RSColors.textOnSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '#$shortId',
                    style: RSTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (!order.isSynced)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded, color: Colors.orange.shade700, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Sin sincronizar',
                        style: RSTypography.labelSmall.copyWith(color: Colors.orange.shade700),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: RSColors.outlineVariant),
          const SizedBox(height: 16),

          // Items list
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: RSColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: RSTypography.labelMedium.copyWith(
                          color: RSColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.productName,
                        style: RSTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),
          Container(height: 1, color: RSColors.outlineVariant),
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: Bs. ${order.total.toStringAsFixed(2)}',
              style: RSTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: RSColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeeplinkInfo(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RSColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RSColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: RSColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pantalla abierta vía deeplink:\nrestaurantesaas://orders/${order.id}',
              style: RSTypography.labelSmall.copyWith(
                color: RSColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple decorative circle pattern painter for the status hero
class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.1), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.9), 40, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}