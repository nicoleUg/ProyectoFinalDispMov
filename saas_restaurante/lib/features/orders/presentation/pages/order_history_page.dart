import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../../../../Core/layout/main_layout.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_history_card.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final primary = RSColors.primary;
  final background = RSColors.background;

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
        leading: isWideScreen
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
              ),
        title: Text(
          'Historial de Pedidos',
          style: RSTypography.titleMedium.copyWith(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
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

            return RefreshIndicator(
              color: primary,
              onRefresh: () async {
                context.read<OrdersBloc>().add(LoadMyOrdersRequested());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return GestureDetector(
                    onTap: () => context.go('/orders/${order.id}'),
                    child: OrderHistoryCard(order: order),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

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
            'Sin pedidos',
            style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes ningún pedido en tu historial todavía.',
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
}
