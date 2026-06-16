import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final primary = const Color(0xFFB02F00);
  final background = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(LoadMyOrdersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('BurgerDash', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return Center(child: CircularProgressIndicator(color: primary));
          }
          
          if (state is OrdersError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is MyOrdersLoaded) {
            if (state.orders.isEmpty) {
              return const Center(child: Text('No tienes órdenes activas.', style: TextStyle(fontSize: 16)));
            }

            final currentOrder = state.orders.first;
            final isPreparing = currentOrder.status == 'preparing';
            final isReady = currentOrder.status == 'ready';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      _buildStatusHero(currentOrder.status),
                      const SizedBox(height: 24),
                      
                      _buildTimelineCard(isPreparing, isReady),
                      const SizedBox(height: 24),

                      _buildOrderSummary(currentOrder),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatusHero(String status) {
    String title = status == 'ready' ? 'Order Ready!' : 'Preparing Order';
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=500'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('Estimated arrival: 7:45 PM', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineCard(bool isPreparing, bool isReady) {
    double progress = isReady ? 1.0 : (isPreparing ? 0.5 : 0.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE4BEB4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(height: 4, color: Colors.grey.shade200),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(height: 4, color: primary),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNode(Icons.check, 'Received', true, isActive: !isPreparing && !isReady),
                _buildNode(Icons.skillet, 'Preparing', isPreparing || isReady, isActive: isPreparing),
                _buildNode(Icons.directions_bike, 'Ready', isReady, isActive: isReady),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(IconData icon, String label, bool isCompleted, {bool isActive = false}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? primary : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: const Color(0xFFFF5722), width: 3) : null,
          ),
          child: Icon(icon, color: isCompleted || isActive ? Colors.white : Colors.grey, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildOrderSummary(order) {
    final shortId = order.id.toString().substring(0, 4).toUpperCase();
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE4BEB4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ORDER NUMBER', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
                    Text('#$shortId', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (!order.isSynced)
                  const Row(
                    children: [
                      Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text('Pending Sync', style: TextStyle(color: Colors.orange, fontSize: 12)),
                    ],
                  ),
              ],
            ),
            const Divider(height: 32),
            
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                    child: Text('${item.quantity}x', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Text(item.productName, style: const TextStyle(fontSize: 16)),
                ],
              ),
            )).toList(),
            
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Total: \$${order.total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary)),
            )
          ],
        ),
      ),
    );
  }
}