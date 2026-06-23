import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_item_tile.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_event.dart';
import '../../../orders/presentation/bloc/orders_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF8F9FA);
    final surfaceContainerLowest = const Color(0xFFFFFFFF);
    final surfaceContainerLow = const Color(0xFFF3F4F5);
    final surfaceVariant = const Color(0xFFE1E3E4);
    final primary = const Color(0xFFB02F00);
    
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Mi Carrito',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            label: const Text('Volver al Menú', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocListener<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
            );
          } else if (state is OrderPlacedSuccess) {
            context.read<CartCubit>().clearCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Pedido confirmado con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/orders/${state.orderId}');
          }
        },
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator(color: primary));
            }

            if (state.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.shopping_cart_outlined, size: 72, color: primary),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Tu carrito está vacío',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explora nuestro menú y añade platos a tu carrito.',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('Ver el Menú'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800), 
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      const Text('Platos Seleccionados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      
                      ...state.items.map((item) => CartItemTile(
                            item: item,
                            onRemoved: () {
                              context.read<CartCubit>().updateQuantity(item.productId, 0); 
                            },
                            onQuantityChanged: (newQty) {
                              context.read<CartCubit>().updateQuantity(item.productId, newQty);
                            },
                          )),
                      
                      const SizedBox(height: 24),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: surfaceVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit_note, color: Colors.grey.shade700),
                                const SizedBox(width: 8),
                                const Text('Notas para la Cocina', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: "Ej: sin cebolla, extra picante...",
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                filled: true,
                                fillColor: surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: surfaceVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Resumen del Pedido', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal'),
                                Text('Bs. ${state.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Costo de Servicio'),
                                Text('Bs. 2.00', style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Text(
                                  'Bs. ${(state.total + 2.0).toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      BlocBuilder<OrdersBloc, OrdersState>(
                        builder: (context, ordersState) {
                          final isConfirming = ordersState is OrdersLoading;
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              ),
                              onPressed: isConfirming
                                  ? null
                                  : () {
                                      context.read<OrdersBloc>().add(
                                        ConfirmOrderRequested(
                                          cartItems: state.items,
                                          total: state.total + 2.0,
                                        ),
                                      );
                                    },
                              label: isConfirming
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Confirmar Pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              icon: isConfirming ? null : const Icon(Icons.check_circle),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('Pedido 100% seguro', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}