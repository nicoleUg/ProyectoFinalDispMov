import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../blocs/menu_bloc.dart';
import '../blocs/menu_event.dart';
import '../blocs/menu_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../deeplinking/presentation/widgets/deeplink_simulator_dialog.dart';
import '../../../../Core/injection_container.dart' as di;
import '../../../../Core/secure_storage/secure_storage_service.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Color primaryColor = const Color(0xFFB02F00);
  String? _currentTableId;

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(LoadMenuRequested());
    _loadCurrentTable();
  }

  Future<void> _loadCurrentTable() async {
    final storage = di.sl<SecureStorageService>();
    final tableId = await storage.getTableId();
    if (mounted) {
      setState(() => _currentTableId = tableId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Restaurante SaaS', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Escanear Mesa',
            onPressed: () => context.go('/scanner'),
          ),
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Simular Deeplink',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DeeplinkSimulatorDialog(),
              );
            },
          ),
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
                // --- INDICADOR DE MESA ACTIVA ---
                if (_currentTableId != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: const Color(0xFF1B5E20).withOpacity(0.08),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.table_restaurant_rounded,
                              size: 16, color: Color(0xFF1B5E20)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mesa #$_currentTableId activa',
                          style: RSTypography.labelMedium.copyWith(
                            color: const Color(0xFF1B5E20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.go('/scanner'),
                          child: Text(
                            'Cambiar',
                            style: RSTypography.labelSmall.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          onTap: () => context.go('/product/${product.id}'),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BlocBuilder<FavoritesBloc, FavoritesState>(
                                builder: (context, state) {
                                  bool isFav = false;
                                  if (state is FavoritesLoaded) {
                                    isFav = state.favorites.any((f) => f.productId == product.id);
                                  }
                                  return IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      context.read<FavoritesBloc>().add(ToggleFavoriteRequested(product.id));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isFav
                                                ? 'Quitado de favoritos'
                                                : 'Agregado a favoritos',
                                          ),
                                          duration: const Duration(milliseconds: 700),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.add, color: primaryColor),
                                  onPressed: () {
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
                            ],
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