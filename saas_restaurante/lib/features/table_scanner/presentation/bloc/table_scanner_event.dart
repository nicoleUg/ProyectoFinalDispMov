part of 'table_scanner_bloc.dart';

abstract class TableScannerEvent {}

/// Verifica y solicita el permiso de cámara.
class RequestCameraPermission extends TableScannerEvent {}

/// El escáner detectó un código QR válido con su contenido.
class QrCodeDetected extends TableScannerEvent {
  final String rawValue;
  QrCodeDetected(this.rawValue);
}

/// Reinicia el escáner para permitir una nueva lectura.
class ResetScanner extends TableScannerEvent {}
