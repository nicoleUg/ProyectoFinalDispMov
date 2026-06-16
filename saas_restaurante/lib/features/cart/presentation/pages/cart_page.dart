import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_item_tile.dart';

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
          'Your Cart',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
            },
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            label: const Text('Back to Menu', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          if (state.items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800), 
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    const Text('Selected Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                              const Text('Kitchen Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: "e.g., 'no onions', 'extra crispy'",
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
                          const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal'),
                              Text('\$${state.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Fee'),
                              Text('\$2.00', style: TextStyle(fontWeight: FontWeight.w600)), // Valor estático por ahora
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
                                '\$${(state.total + 2.0).toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: () {
                            context.read<OrdersBloc>().add(
                              ConfirmOrderRequested(
                                cartItems: state.items,
                                total: state.total + 2.0,
                              ),
                            );
                        },
                        label: const Text('Confirm Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        icon: const Icon(Icons.check_circle),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('Secure checkout', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
    );
  }
}