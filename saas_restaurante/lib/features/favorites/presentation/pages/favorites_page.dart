import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../Core/layout/main_layout.dart';
import '../../presentation/bloc/favorites_bloc.dart';
import '../../presentation/bloc/favorites_event.dart';
import '../../presentation/bloc/favorites_state.dart';
import '../../../menu/presentation/blocs/menu_bloc.dart';
import '../../../menu/presentation/blocs/menu_state.dart';
import '../../../menu/domain/entities/product_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  ProductEntity? _findProduct(List<ProductEntity> products, String productId) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFB02F00);
    final bool isWideScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
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
        title: const Text('Platos Favoritos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, menuState) {
          if (menuState is! MenuLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProducts = menuState.products;

          return BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, favState) {
              if (favState is FavoritesLoading) {
                return Center(child: CircularProgressIndicator(color: primaryColor));
              }

              if (favState is FavoritesError) {
                return Center(child: Text('Error: ${favState.message}'));
              }

              List<ProductEntity> favProducts = [];
              if (favState is FavoritesLoaded) {
                for (final fav in favState.favorites) {
                  // NUEVO: Usar el producto anidado desde el backend si está disponible.
                  // Esto permite ver favoritos de cualquier categoría sin importar la actual.
                  if (fav.product != null) {
                    favProducts.add(fav.product!);
                  } else {
                    // FALLBACK: Buscar localmente si la API no trajo el producto anidado (ej. modo offline)
                    final prod = _findProduct(allProducts, fav.productId);
                    if (prod != null) {
                      favProducts.add(prod);
                    }
                  }
                }
              }

              if (favProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 72,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aún no tienes favoritos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explora nuestro menú y guarda tus platos preferidos aquí.',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Explorar Menú'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favProducts.length,
                itemBuilder: (context, index) {
                  final product = favProducts[index];
                  final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    child: InkWell(
                      onTap: () => context.go('/product/${product.id}'),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image or Icon
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade100,
                                child: hasImage
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(Icons.fastfood_rounded, color: Colors.grey.shade400),
                                      )
                                    : Icon(Icons.fastfood_rounded, color: Colors.grey.shade400),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Bs. ${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Row(
                                        children: [
                                          // Remove button
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            tooltip: 'Quitar de favoritos',
                                            onPressed: () {
                                              context.read<FavoritesBloc>().add(ToggleFavoriteRequested(product.id));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Quitado de favoritos'),
                                                  duration: Duration(milliseconds: 700),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 4),
                                          // Add to cart
                                          IconButton(
                                            icon: Icon(Icons.add_shopping_cart, color: primaryColor),
                                            tooltip: 'Agregar al carrito',
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
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}