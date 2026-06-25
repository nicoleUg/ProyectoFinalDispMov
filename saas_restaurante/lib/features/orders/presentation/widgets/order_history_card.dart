import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
class OrderHistoryCard extends StatelessWidget {
  final OrderEntity order;

  const OrderHistoryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String statusText;
    final Color statusColor;
    
    switch (order.status.toLowerCase()) {
      case 'delivered':
        statusText = 'Entregado';
        statusColor = Colors.green;
        break;
      case 'ready':
        statusText = 'Listo';
        statusColor = Colors.green;
        break;
      case 'preparing':
        statusText = 'Preparando';
        statusColor = Colors.orange;
        break;
      case 'pending':
      default:
        statusText = 'Pendiente';
        statusColor = Colors.blue;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order.id.length >= 5 ? order.id.substring(0, 5) : order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${order.items.length} productos • Bs. ${order.total.toStringAsFixed(2)}'),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  _reorderItems(context, order.items);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Pedir de nuevo'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Lógica de UI súper limpia
  void _reorderItems(BuildContext context, List<OrderItemEntity> items) async {
    final cartCubit = context.read<CartCubit>();

    // Le delegamos el trabajo pesado al Cubit y esperamos un bool de respuesta
    final success = await cartCubit.reorderPreviousItems(items);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Productos agregados al carrito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudieron agregar los productos al carrito'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}