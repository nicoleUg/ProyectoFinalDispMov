import 'package:permission_handler/permission_handler.dart';

/// Repositorio de dominio para el escáner de mesa.
/// Define el contrato de permisos y lectura de QR.
abstract class TableScannerRepository {
  /// Verifica el estado actual del permiso de cámara.
  Future<PermissionStatus> checkCameraPermission();

  /// Solicita el permiso de cámara al usuario.
  Future<PermissionStatus> requestCameraPermission();
}
