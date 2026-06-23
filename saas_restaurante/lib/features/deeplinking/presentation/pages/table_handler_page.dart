import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../../../../Core/injection_container.dart' as di;
import '../../../../Core/secure_storage/secure_storage_service.dart';

class TableHandlerPage extends StatefulWidget {
  final String tableId;
  const TableHandlerPage({super.key, required this.tableId});

  @override
  State<TableHandlerPage> createState() => _TableHandlerPageState();
}

class _TableHandlerPageState extends State<TableHandlerPage> {
  @override
  void initState() {
    super.initState();
    _saveTableAndRedirect();
  }

  Future<void> _saveTableAndRedirect() async {
    final storage = di.sl<SecureStorageService>();
    // Store in secure storage
    await storage.saveTableId(widget.tableId);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mesa #${widget.tableId} configurada correctamente'),
        backgroundColor: const Color(0xFF1B5E20),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Go to catalog
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: RSColors.background,
      body: Center(
        child: CircularProgressIndicator(color: RSColors.primary),
      ),
    );
  }
}
