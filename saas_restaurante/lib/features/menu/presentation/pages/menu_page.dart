import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/menu_bloc.dart';
import '../blocs/menu_event.dart';
import '../blocs/menu_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Color primaryColor = const Color(0xFFB02F00);

  @override
  void initState() {
    super.initState();
    // Apenas se abre la pantalla, le pedimos al BLoC que traiga los datos de NestJS
    context.read<MenuBloc>().add(LoadMenuRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('GourmetFlow', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Aquí navegaremos al carrito más adelante
            },
          )
        ],
      ),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is MenuInitial || state is MenuLoading) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (state is MenuError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  TextButton(
                    onPressed: () => context.read<MenuBloc>().add(LoadMenuRequested()),
                    child: Text('Reintentar', style: TextStyle(color: primaryColor)),
                  )
                ],
              ),
            );
          }

          if (state is MenuLoaded) {
            if (state.categories.isEmpty) {
              return const Center(child: Text('Aún no hay platos en el menú.'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CINTA DE CATEGORÍAS ---
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      final isSelected = category.id == state.selectedCategoryId;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category.name),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              context.read<MenuBloc>().add(CategorySelected(category.id));
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // --- LISTA DE PRODUCTOS ---
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Text(
                                  'Bs. ${product.price.toStringAsFixed(2)}', 
                                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add, color: primaryColor),
                              onPressed: () {
                                // Lógica para agregar al carrito local con Drift/CartCubit
                                context.read<CartCubit>().addItem(CartItemEntity(
                                  productId: product.id,
                                  name: product.name,
                                  price: product.price,
                                  quantity: 1,
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} agregado al carrito'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}