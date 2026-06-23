part of 'table_scanner_bloc.dart';

abstract class TableScannerState {}

/// Estado inicial antes de verificar permisos.
class TableScannerInitial extends TableScannerState {}

/// Verificando o solicitando permiso.
class TableScannerPermissionLoading extends TableScannerState {}

/// Permiso de cámara concedido — listo para escanear.
class TableScannerPermissionGranted extends TableScannerState {}

/// Permiso de cámara denegado por el usuario.
class TableScannerPermissionDenied extends TableScannerState {
  /// Si es true, el usuario ha marcado "No volver a preguntar".
  final bool isPermanentlyDenied;
  TableScannerPermissionDenied({this.isPermanentlyDenied = false});
}

/// Se detectó un código QR y fue procesado.
class TableScannerQrDetected extends TableScannerState {
  final String rawValue;
  final String? tableId; // null si el QR no sigue el formato restaurantesaas://table/X
  TableScannerQrDetected({required this.rawValue, this.tableId});
}

/// Navegando a la mesa — procesando el deeplink internamente.
class TableScannerNavigating extends TableScannerState {
  final String tableId;
  TableScannerNavigating(this.tableId);
}

/// Error genérico.
class TableScannerError extends TableScannerState {
  final String message;
  TableScannerError(this.message);
}
