import 'package:flutter/material.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';

/// Placeholder para el Commit 1 — la implementación completa
/// llega en el Commit 2 con mobile_scanner + UI de cámara.
class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RSColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: RSColors.primary,
        elevation: 0,
        title: Text(
          'Escáner de Mesa',
          style: RSTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: RSColors.primary,
          ),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: RSColors.primary),
      ),
    );
  }
}
