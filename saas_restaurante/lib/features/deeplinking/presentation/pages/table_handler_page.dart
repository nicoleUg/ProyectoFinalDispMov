import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../../../../Core/injection_container.dart' as di;
import '../../../../Core/secure_storage/secure_storage_service.dart';

/// Página de confirmación de mesa.
/// Guarda el tableId en SecureStorage y muestra una pantalla de éxito
/// animada con cuenta regresiva antes de redirigir al catálogo.
class TableHandlerPage extends StatefulWidget {
  final String tableId;
  const TableHandlerPage({super.key, required this.tableId});

  @override
  State<TableHandlerPage> createState() => _TableHandlerPageState();
}

class _TableHandlerPageState extends State<TableHandlerPage>
    with TickerProviderStateMixin {
  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _checkController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  late Animation<double> _checkAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // ── Countdown ─────────────────────────────────────────────────────────────
  int _countdown = 3;
  Timer? _countdownTimer;

  bool _saved = false;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _checkAnim = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
    _scaleAnim = CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _saveAndAnimate();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveAndAnimate() async {
    // 1. Guardar mesa en almacenamiento seguro
    final storage = di.sl<SecureStorageService>();
    await storage.saveTableId(widget.tableId);
    _saved = true;

    if (!mounted) return;

    // 2. Lanzar animaciones en cascada
    await _fadeController.forward();
    await _scaleController.forward();
    _checkController.forward();

    // 3. Iniciar cuenta regresiva para redirigir
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        timer.cancel();
        _goToMenu();
      }
    });
  }

  void _goToMenu() {
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2B0D), // Dark green background
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ── Success icon with animated scale ──────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1B5E20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ScaleTransition(
                      scale: _checkAnim,
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 72,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ── "Mesa Configurada" label ───────────────────────────────
                Text(
                  '¡Mesa Configurada!',
                  style: RSTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // ── Table number badge ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.table_restaurant_rounded,
                          color: Color(0xFF81C784), size: 26),
                      const SizedBox(width: 12),
                      Text(
                        'Mesa  #${widget.tableId}',
                        style: RSTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Description ───────────────────────────────────────────
                Text(
                  'Tu mesa ha sido registrada correctamente.\nTus pedidos se asignarán a esta mesa.',
                  style: RSTypography.bodyMedium.copyWith(
                    color: Colors.white70,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // ── Countdown circle ──────────────────────────────────────
                _CountdownRing(countdown: _countdown, total: 3),
                const SizedBox(height: 8),
                Text(
                  'Redirigiendo al menú en $_countdown...',
                  style: RSTypography.bodySmall.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 28),

                // ── Go now button ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: RSButton.filled(
                    label: 'Ir al Menú Ahora',
                    onPressed: () {
                      _countdownTimer?.cancel();
                      _goToMenu();
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Countdown Ring Widget ───────────────────────────────────────────────────
class _CountdownRing extends StatelessWidget {
  final int countdown;
  final int total;
  const _CountdownRing({required this.countdown, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = countdown / total;
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          Text(
            '$countdown',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
