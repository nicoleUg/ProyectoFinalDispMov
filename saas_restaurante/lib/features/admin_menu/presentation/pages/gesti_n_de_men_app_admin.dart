import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../bloc/admin_menu_bloc.dart';
import '../bloc/admin_menu_event.dart';
import '../bloc/admin_menu_state.dart';
import '../../../menu/domain/entities/category_entity.dart';
import '../../../menu/domain/entities/product_entity.dart';
import '../../../admin_reports/presentation/widgets/admin_drawer.dart';

class GestiNDeMenAppAdmin extends StatefulWidget {
  const GestiNDeMenAppAdmin({super.key});

  @override
  State<GestiNDeMenAppAdmin> createState() => _GestiNDeMenAppAdminState();
}

class _GestiNDeMenAppAdminState extends State<GestiNDeMenAppAdmin> {
  String? _selectedCategoryId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<AdminMenuBloc>().add(LoadAdminMenuRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: RSColors.background,
      drawer: isDesktop
          ? null
          : const Drawer(
              child: AdminDrawer(activeRoute: '/admin-menu', isMobileDrawer: true),
            ),
      body: Row(
        children: [
          if (isDesktop)
            const AdminDrawer(activeRoute: '/admin-menu', isMobileDrawer: false),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isDesktop),
                Expanded(
                  child: BlocConsumer<AdminMenuBloc, AdminMenuState>(
                    listener: (context, state) {
                      if (state is AdminMenuActionSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.read<AdminMenuBloc>().add(LoadAdminMenuRequested());
                      }
                      if (state is AdminMenuError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: RSColors.error,
                          ),
                        );
                      }
                      if (state is AdminMenuLoaded) {
                        if (_selectedCategoryId == null && state.categories.isNotEmpty) {
                          setState(() {
                            _selectedCategoryId = state.selectedCategoryId ?? state.categories.first.id;
                          });
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminMenuLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: RSColors.primary),
                        );
                      }

                      if (state is AdminMenuLoaded) {
                        return _buildMenuContent(state);
                      }

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No se pudieron cargar los datos del menú',
                              style: RSTypography.bodyLarge,
                            ),
                            RSSpacing.verticalMd,
                            RSButton.filled(
                              label: 'Reintentar',
                              onPressed: () {
                                context.read<AdminMenuBloc>().add(LoadAdminMenuRequested());
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin-menu/new-product');
        },
        backgroundColor: RSColors.primaryContainer,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
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
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  );
                },
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Menu',
                  style: RSTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Manage item availability and pricing.',
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

  Widget _buildMenuContent(AdminMenuLoaded state) {
    final selectedCategoryProducts = state.products.where((p) {
      if (_selectedCategoryId == null) return true;
      return p.categoryId == _selectedCategoryId;
    }).toList();

    return Column(
      children: [
        _buildCategoryTabs(state.categories),
        Expanded(
          child: selectedCategoryProducts.isEmpty
              ? _buildEmptyProductsView()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: selectedCategoryProducts.length,
                  itemBuilder: (context, index) {
                    final product = selectedCategoryProducts[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(List<CategoryEntity> categories) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.id == _selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: RSChoiceChip(
              label: cat.name,
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategoryId = cat.id;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    final isAvailable = product.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: RSCard(
        backgroundColor: isAvailable ? RSColors.surfaceContainerLowest : RSColors.background.withOpacity(0.5),
        borderColor: isAvailable ? RSColors.outlineVariant : RSColors.outlineVariant.withOpacity(0.1),
        padding: const EdgeInsets.all(RSSpacing.md),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: RSColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl!),
                        fit: BoxFit.cover,
                        colorFilter: !isAvailable
                            ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                            : null,
                      )
                    : null,
              ),
              child: product.imageUrl == null || product.imageUrl!.isEmpty
                  ? const Icon(
                      Icons.fastfood_outlined,
                      color: RSColors.primary,
                      size: 32,
                    )
                  : null,
            ),
            RSSpacing.horizontalMd,
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: RSTypography.titleMedium.copyWith(
                            color: isAvailable ? Colors.black87 : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: RSTypography.titleMedium.copyWith(
                          color: isAvailable ? RSColors.primary : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  RSSpacing.verticalXs,
                  Text(
                    product.description,
                    style: RSTypography.bodyMedium.copyWith(
                      color: isAvailable ? RSColors.textOnSurfaceVariant : Colors.grey.shade400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  RSSpacing.verticalMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Availability switch
                      Row(
                        children: [
                          Switch(
                            value: isAvailable,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} ${value ? "disponible" : "fuera de stock"}',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            activeColor: RSColors.primary,
                          ),
                          RSSpacing.horizontalSm,
                          Text(
                            isAvailable ? 'Available' : 'Out of Stock',
                            style: RSTypography.labelLarge.copyWith(
                              color: isAvailable ? Colors.black87 : RSColors.error,
                            ),
                          ),
                        ],
                      ),
                      // Actions: Edit and Delete
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              context.push('/admin-menu/edit-product', extra: product);
                            },
                            color: RSColors.textOnSurfaceVariant,
                            iconSize: 20,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDelete(product),
                            color: RSColors.error,
                            iconSize: 20,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
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
    );
  }

  Widget _buildEmptyProductsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          RSSpacing.verticalMd,
          Text(
            'No hay productos en esta categoría',
            style: RSTypography.bodyLarge.copyWith(color: RSColors.textOnSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ProductEntity product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: Text('¿Estás seguro de que deseas eliminar "${product.name}" de la carta?'),
          actions: [
            RSButton.tonal(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
              size: RSButtonSize.small,
            ),
            RSButton.filled(
              label: 'Eliminar',
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto "${product.name}" eliminado con éxito'),
                    backgroundColor: RSColors.error,
                  ),
                );
              },
              size: RSButtonSize.small,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: RSColors.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/admin-dashboard');
          if (index == 2) context.go('/admin-orders');
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
}
