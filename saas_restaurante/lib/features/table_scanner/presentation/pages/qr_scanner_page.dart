import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../bloc/table_scanner_bloc.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with TickerProviderStateMixin {
  // ── Mobile Scanner controller ────────────────────────────────────────────
  late final MobileScannerController _scannerController;

  // ── Scan line animation ──────────────────────────────────────────────────
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  // ── Corner pulse animation ───────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Solicitar permiso de cámara al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TableScannerBloc>().add(RequestCameraPermission());
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _lineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    _hasScanned = true;
    // Feedback háptico al detectar QR
    HapticFeedback.mediumImpact();
    // Segundo pulso tras 200ms para efecto "double tap"
    Future.delayed(const Duration(milliseconds: 200), HapticFeedback.lightImpact);

    context.read<TableScannerBloc>().add(QrCodeDetected(barcode!.rawValue!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TableScannerBloc, TableScannerState>(
      listener: (context, state) {
        if (state is TableScannerNavigating) {
          // Navega al handler de mesa que guardará el tableId y redirigirá
          context.go('/table/${state.tableId}');
        } else if (state is TableScannerQrDetected && state.tableId == null) {
          // QR detectado pero no es un deeplink válido de restaurante
          _hasScanned = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'QR no reconocido: ${state.rawValue}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFE65100),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<TableScannerBloc, TableScannerState>(
          builder: (context, state) {
            if (state is TableScannerPermissionLoading ||
                state is TableScannerInitial) {
              return _buildLoading();
            }

            if (state is TableScannerPermissionDenied) {
              return _buildPermissionDenied(state.isPermanentlyDenied);
            }

            if (state is TableScannerPermissionGranted ||
                state is TableScannerQrDetected ||
                state is TableScannerNavigating) {
              return Stack(
                children: [
                  _buildScanner(),
                  // Flash verde de éxito cuando se detecta QR válido
                  if (state is TableScannerQrDetected && state.tableId != null)
                    _buildSuccessFlash(state.tableId!),
                  if (state is TableScannerNavigating)
                    _buildSuccessFlash(state.tableId),
                ],
              );
            }

            return _buildLoading();
          },
        ),
      ),
    );
  }

  // ── Views ────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: RSColors.background,
      appBar: _buildAppBar(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: RSColors.primary),
            SizedBox(height: 20),
            Text('Iniciando cámara...', style: TextStyle(color: RSColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDenied(bool isPermanent) {
    return Scaffold(
      backgroundColor: RSColors.background,
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with glow effect
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RSColors.primary.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: RSColors.primary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.no_photography_rounded,
                  size: 48,
                  color: RSColors.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                isPermanent ? 'Permiso bloqueado' : 'Cámara no permitida',
                style: RSTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isPermanent
                    ? 'Has bloqueado el acceso a la cámara de forma permanente. Ve a Configuración de tu dispositivo para habilitarlo.'
                    : 'Para escanear el código QR de tu mesa necesitamos acceder a la cámara.',
                style: RSTypography.bodyMedium.copyWith(
                  color: RSColors.textOnSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              if (isPermanent)
                RSButton.filled(
                  label: 'Abrir Configuración',
                  onPressed: () async {
                    await openAppSettings();
                  },
                )
              else
                RSButton.filled(
                  label: 'Conceder Permiso',
                  onPressed: () {
                    _hasScanned = false;
                    context.read<TableScannerBloc>().add(RequestCameraPermission());
                  },
                ),
              const SizedBox(height: 12),
              RSButton.tonal(
                label: 'Volver al Menú',
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        // ── Full screen camera feed ──────────────────────────────────────
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
        ),

        // ── Dark overlay with transparent hole ──────────────────────────
        _ScannerOverlay(animation: _pulseAnimation),

        // ── Animated scan line inside the hole ──────────────────────────
        _ScanLine(animation: _lineAnimation),

        // ── Top bar ─────────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Escanear Mesa',
                    style: RSTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(blurRadius: 8, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                // Torch toggle
                GestureDetector(
                  onTap: () => _scannerController.toggleTorch(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flashlight_on_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom hint card ─────────────────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Apunta al código QR de tu mesa',
                        style: RSTypography.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: RSColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go('/'),
      ),
      title: Text(
        'Escáner de Mesa',
        style: RSTypography.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: RSColors.primary,
        ),
      ),
    );
  }

  /// Flash verde semitransparente con el número de mesa.
  /// Se muestra brevemente cuando el QR es reconocido como válido.
  Widget _buildSuccessFlash(String tableId) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF1B5E20).withOpacity(0.88),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated check icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (_, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡QR Reconocido!',
              style: RSTypography.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.table_restaurant_rounded,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Mesa  #$tableId',
                    style: RSTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Configurando tu mesa...',
              style: RSTypography.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Scanner Overlay Widget ──────────────────────────────────────────────────
class _ScannerOverlay extends StatelessWidget {
  final Animation<double> animation;
  const _ScannerOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.72;
    final scanAreaTop = (size.height - scanAreaSize) / 2 - 40;

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return CustomPaint(
          size: Size(size.width, size.height),
          painter: _OverlayPainter(
            scanAreaSize: scanAreaSize,
            scanAreaTop: scanAreaTop,
            pulseScale: animation.value,
          ),
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final double scanAreaTop;
  final double pulseScale;

  _OverlayPainter({
    required this.scanAreaSize,
    required this.scanAreaTop,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black.withOpacity(0.65);
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final cornerPaint = Paint()
      ..color = RSColors.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final left = (size.width - scanAreaSize) / 2;
    final top = scanAreaTop;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
      const Radius.circular(16),
    );

    // Draw darkened overlay
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), dimPaint);
    canvas.drawRRect(rect, clearPaint);
    canvas.restore();

    // Draw corner brackets
    const cornerLen = 28.0;
    final corners = [
      // top-left
      [Offset(left, top + cornerLen), Offset(left, top), Offset(left + cornerLen, top)],
      // top-right
      [Offset(left + scanAreaSize - cornerLen, top), Offset(left + scanAreaSize, top), Offset(left + scanAreaSize, top + cornerLen)],
      // bottom-left
      [Offset(left, top + scanAreaSize - cornerLen), Offset(left, top + scanAreaSize), Offset(left + scanAreaSize * 0 + cornerLen + left, top + scanAreaSize)],
      // bottom-right
      [Offset(left + scanAreaSize - cornerLen, top + scanAreaSize), Offset(left + scanAreaSize, top + scanAreaSize), Offset(left + scanAreaSize, top + scanAreaSize - cornerLen)],
    ];

    for (final pts in corners) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy);
      canvas.drawPath(path, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.pulseScale != pulseScale;
}

// ─── Animated Scan Line Widget ───────────────────────────────────────────────
class _ScanLine extends StatelessWidget {
  final Animation<double> animation;
  const _ScanLine({required this.animation});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.72;
    final scanAreaTop = (size.height - scanAreaSize) / 2 - 40;
    final left = (size.width - scanAreaSize) / 2;

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final lineY = scanAreaTop + scanAreaSize * animation.value;
        return Positioned(
          top: lineY,
          left: left + 8,
          child: Container(
            width: scanAreaSize - 16,
            height: 2.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  RSColors.primary.withOpacity(0.8),
                  RSColors.primary,
                  RSColors.primary.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: RSColors.primary.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
