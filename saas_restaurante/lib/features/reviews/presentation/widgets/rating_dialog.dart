import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../../../../Core/injection_container.dart' as di;
import '../bloc/reviews_bloc.dart';

/// Diálogo para dejar una calificación con estrellas y comentario opcional.
/// Se puede invocar desde cualquier pantalla pasando el [productId] y [productName].
class RatingDialog extends StatefulWidget {
  final String productId;
  final String productName;

  const RatingDialog({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  final _nameController = TextEditingController(text: 'Anónimo');
  bool _submitted = false;

  late AnimationController _successController;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successScale = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _onStarTap(int star) {
    setState(() => _selectedRating = star);
  }

  void _submit(BuildContext ctx) {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona una calificación'),
          backgroundColor: RSColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ctx.read<ReviewsBloc>().add(SubmitReviewRequested(
          productId: widget.productId,
          rating: _selectedRating,
          comment: _commentController.text.trim(),
          userName: _nameController.text.trim().isEmpty
              ? 'Anónimo'
              : _nameController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ReviewsBloc>(),
      child: BlocConsumer<ReviewsBloc, ReviewsState>(
        listener: (ctx, state) {
          if (state is ReviewSubmitted) {
            setState(() => _submitted = true);
            _successController.forward();
            // Auto-cerrar después de 1.5s
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) Navigator.of(context).pop(true);
            });
          } else if (state is ReviewsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (ctx, state) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: RSColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _submitted
                  ? _buildSuccessView()
                  : _buildFormView(ctx, state),
            ),
          );
        },
      ),
    );
  }

  // ── Success view ───────────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _successScale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1B5E20).withOpacity(0.12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Color(0xFF1B5E20), size: 48),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¡Gracias por tu reseña!',
          style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tu opinión ayuda a otros usuarios.',
          style: RSTypography.bodySmall.copyWith(
              color: RSColors.textOnSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Form view ──────────────────────────────────────────────────────────────
  Widget _buildFormView(BuildContext ctx, ReviewsState state) {
    final isLoading = state is ReviewsLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.rate_review_rounded, color: RSColors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Calificar Plato',
                style: RSTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(false),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.productName,
          style: RSTypography.bodyMedium.copyWith(
            color: RSColors.textOnSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 20),

        // ── Star selector ────────────────────────────────────────────────
        Center(
          child: Column(
            children: [
              Text(
                _ratingLabel(_selectedRating),
                style: RSTypography.labelMedium.copyWith(
                  color: _selectedRating > 0
                      ? RSColors.primary
                      : RSColors.textOnSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => _onStarTap(star),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Icon(
                        star <= _selectedRating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: star <= _selectedRating
                            ? const Color(0xFFFFB300)
                            : Colors.grey.shade400,
                        size: star <= _selectedRating ? 44 : 38,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Name field ────────────────────────────────────────────────────
        RSTextField(
          controller: _nameController,
          labelText: 'Tu nombre',
          hintText: 'Anónimo',
        ),
        const SizedBox(height: 12),

        // ── Comment field ─────────────────────────────────────────────────
        RSTextField(
          controller: _commentController,
          labelText: 'Comentario (opcional)',
          hintText: '¿Qué te pareció este plato?',
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        // ── Actions ───────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: RSButton.tonal(
                label: 'Cancelar',
                onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: RSColors.primary))
                  : RSButton.filled(
                      label: 'Enviar',
                      onPressed: () => _submit(ctx),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1: return '😞 Muy malo';
      case 2: return '😕 Malo';
      case 3: return '😐 Regular';
      case 4: return '😊 Bueno';
      case 5: return '🤩 ¡Excelente!';
      default: return 'Selecciona una calificación';
    }
  }
}

/// Helper para mostrar el diálogo de calificación desde cualquier pantalla.
Future<bool?> showRatingDialog(
  BuildContext context, {
  required String productId,
  required String productName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => RatingDialog(
      productId: productId,
      productName: productName,
    ),
  );
}
