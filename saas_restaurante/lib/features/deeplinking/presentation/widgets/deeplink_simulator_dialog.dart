import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';

class DeeplinkSimulatorDialog extends StatefulWidget {
  const DeeplinkSimulatorDialog({super.key});

  @override
  State<DeeplinkSimulatorDialog> createState() => _DeeplinkSimulatorDialogState();
}

class _DeeplinkSimulatorDialogState extends State<DeeplinkSimulatorDialog> {
  final _linkController = TextEditingController(text: 'restaurantesaas://table/5');

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _handleNavigate() {
    final link = _linkController.text.trim();
    if (link.isEmpty) return;

    if (link.startsWith('restaurantesaas://')) {
      final route = link.replaceFirst('restaurantesaas://', '/');
      Navigator.of(context).pop(); // Close dialog
      
      // Navigate using GoRouter
      context.go(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato inválido. Debe comenzar con restaurantesaas://'),
          backgroundColor: RSColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.link, color: RSColors.primary),
          const SizedBox(width: 8),
          Text(
            'Simulador de Deeplink',
            style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresa un enlace profundo para simular su ejecución nativa en la plataforma.',
            style: RSTypography.bodyMedium.copyWith(color: RSColors.textOnSurfaceVariant),
          ),
          const SizedBox(height: 16),
          RSTextField(
            controller: _linkController,
            labelText: 'Enlace Deeplink',
            hintText: 'restaurantesaas://...',
          ),
          const SizedBox(height: 12),
          Text(
            'Ejemplos de prueba:\n'
            '• restaurantesaas://table/5 (Mesa)\n'
            '• restaurantesaas://product/1 (Detalle de Plato)\n'
            '• restaurantesaas://orders/ord123 (Seguimiento)',
            style: RSTypography.labelSmall.copyWith(
              color: RSColors.textOnSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        RSButton.tonal(
          label: 'Cancelar',
          size: RSButtonSize.small,
          onPressed: () => Navigator.of(context).pop(),
        ),
        RSButton.filled(
          label: 'Ir al Enlace',
          size: RSButtonSize.small,
          onPressed: _handleNavigate,
        ),
      ],
    );
  }
}
