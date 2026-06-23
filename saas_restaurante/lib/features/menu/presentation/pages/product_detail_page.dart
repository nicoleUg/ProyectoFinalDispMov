import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../blocs/menu_bloc.dart';
import '../blocs/menu_event.dart';
import '../blocs/menu_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../Core/injection_container.dart' as di;
import '../../../reviews/presentation/bloc/reviews_bloc.dart';
import '../../../reviews/presentation/widgets/rating_dialog.dart';
import '../../../reviews/domain/entities/review_entity.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // If menu not loaded yet, trigger load
    final menuState = context.read<MenuBloc>().state;
    if (menuState is! MenuLoaded) {
      context.read<MenuBloc>().add(LoadMenuRequested());
    }
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  ProductEntity? _findProduct(MenuState state) {
    if (state is MenuLoaded) {
      try {
        return state.products.firstWhere((p) => p.id == widget.productId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ReviewsBloc>()..add(LoadReviewsRequested(widget.productId)),
      child: Scaffold(
        backgroundColor: RSColors.background,
        body: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoading || state is MenuInitial) {
              return const Center(
                child: CircularProgressIndicator(color: RSColors.primary),
              );
            }

            final product = _findProduct(state);

            if (product == null) {
              return _buildNotFound(context);
            }

            return _buildContent(context, product);
          },
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      backgroundColor: RSColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: RSColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: RSColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 64, color: RSColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Plato no encontrado',
              style: RSTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No existe un plato con el ID: ${widget.productId}',
              style: RSTypography.bodyMedium.copyWith(color: RSColors.textOnSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            RSButton.filled(
              label: 'Ver Menú Completo',
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductEntity product) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;

    return CustomScrollView(
      slivers: [
        // ─── Hero Image App Bar ───────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: RSColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            ),
            onPressed: () => context.go('/'),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildImagePlaceholder(),
          ),
        ),

        // ─── Content ─────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Availability badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.isAvailable
                            ? const Color(0xFF1B5E20).withOpacity(0.12)
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? const Color(0xFF1B5E20)
                                  : Colors.red.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.isAvailable ? 'Disponible' : 'No disponible',
                            style: RSTypography.labelSmall.copyWith(
                              color: product.isAvailable
                                  ? const Color(0xFF1B5E20)
                                  : Colors.red.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Name & price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: RSTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: RSColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Bs. ${product.price.toStringAsFixed(2)}',
                            style: RSTypography.titleLarge.copyWith(
                              color: RSColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Container(height: 1, color: RSColors.outlineVariant),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'Descripción',
                      style: RSTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description.isNotEmpty
                          ? product.description
                          : 'Sin descripción disponible.',
                      style: RSTypography.bodyMedium.copyWith(
                        color: RSColors.textOnSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Info chips row
                    Row(
                      children: [
                        _InfoChip(icon: Icons.tag_rounded, label: 'ID: ${widget.productId.length > 6 ? widget.productId.substring(0, 6) : widget.productId}...'),
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.local_offer_rounded, label: 'Bs. ${product.price.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // ─── Add to cart button ───────────────────────────────────
                    if (product.isAvailable)
                      RSButton.filled(
                        label: 'Agregar al Carrito',
                        onPressed: () {
                          context.read<CartCubit>().addItem(CartItemEntity(
                            productId: product.id,
                            name: product.name,
                            price: product.price,
                            quantity: 1,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text('${product.name} agregado al carrito'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF1B5E20),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          context.go('/');
                        },
                      )
                    else
                      RSButton.tonal(
                        label: 'No disponible por ahora',
                        onPressed: null,
                      ),
                    const SizedBox(height: 16),
                    RSButton.tonal(
                      label: 'Volver al Menú',
                      onPressed: () => context.go('/'),
                    ),
                    const SizedBox(height: 16),
                    _buildReviewsSection(context, product),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RSColors.primary.withOpacity(0.8),
            RSColors.primary,
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.fastfood_rounded, size: 96, color: Colors.white30),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, ProductEntity product) {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, state) {
        if (state is ReviewsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: RSColors.primary),
            ),
          );
        }

        List<ReviewEntity> reviews = [];
        double avgRating = 0.0;

        if (state is ReviewsLoaded) {
          reviews = state.reviews;
          avgRating = state.averageRating;
        } else if (state is ReviewSubmitted) {
          reviews = state.reviews;
          avgRating = state.averageRating;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Calificaciones y Reseñas',
              style: RSTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            // Summary Card
            RSCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: RSTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: RSColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < avgRating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFFFB300),
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reviews.length} ${reviews.length == 1 ? 'opinión' : 'opiniones'}',
                        style: RSTypography.bodySmall.copyWith(
                          color: RSColors.textOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        final starLevel = 5 - index;
                        final count = reviews.where((r) => r.rating == starLevel).length;
                        final pct = reviews.isEmpty ? 0.0 : count / reviews.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$starLevel',
                                style: RSTypography.labelSmall.copyWith(
                                  color: RSColors.textOnSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: RSColors.surfaceContainerLow,
                                    color: const Color(0xFFFFB300),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$count',
                                style: RSTypography.labelSmall.copyWith(
                                  color: RSColors.textOnSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opiniones',
                  style: RSTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await showRatingDialog(
                      context,
                      productId: product.id,
                      productName: product.name,
                    );
                    if (result == true && context.mounted) {
                      context.read<ReviewsBloc>().add(LoadReviewsRequested(product.id));
                    }
                  },
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: Text(
                    'Calificar',
                    style: RSTypography.labelMedium.copyWith(color: RSColors.primary),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: RSColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 40,
                        color: RSColors.textOnSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aún no hay opiniones para este plato.',
                        style: RSTypography.bodyMedium.copyWith(
                          color: RSColors.textOnSurfaceVariant,
                        ),
                      ),
                      Text(
                        '¡Sé el primero en calificarlo!',
                        style: RSTypography.bodySmall.copyWith(
                          color: RSColors.textOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RSCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                review.userName,
                                style: RSTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                style: RSTypography.labelSmall.copyWith(
                                  color: RSColors.textOnSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(5, (starIdx) {
                              return Icon(
                                starIdx < review.rating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: const Color(0xFFFFB300),
                                size: 16,
                              );
                            }),
                          ),
                          if (review.comment.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              review.comment,
                              style: RSTypography.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: RSColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: RSColors.textOnSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: RSTypography.labelSmall.copyWith(color: RSColors.textOnSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
