import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/table_scanner_repository.dart';

/// Implementación real del repositorio usando el paquete permission_handler.
class TableScannerRepositoryImpl implements TableScannerRepository {
  @override
  Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  @override
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }
}
