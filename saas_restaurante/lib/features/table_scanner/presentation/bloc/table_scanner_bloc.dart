import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/table_scanner_repository.dart';

part 'table_scanner_event.dart';
part 'table_scanner_state.dart';

/// BLoC que gestiona:
/// 1. El ciclo de vida del permiso de cámara (via permission_handler).
/// 2. El procesamiento del código QR escaneado (via mobile_scanner).
/// 3. La lógica de extracción del tableId del formato restaurantesaas://table/{id}.
class TableScannerBloc extends Bloc<TableScannerEvent, TableScannerState> {
  final TableScannerRepository _repository;

  TableScannerBloc(this._repository) : super(TableScannerInitial()) {
    on<RequestCameraPermission>(_onRequestPermission);
    on<QrCodeDetected>(_onQrDetected);
    on<ResetScanner>(_onReset);
  }

  Future<void> _onRequestPermission(
    RequestCameraPermission event,
    Emitter<TableScannerState> emit,
  ) async {
    emit(TableScannerPermissionLoading());
    try {
      // 1. Verificar estado actual
      final status = await _repository.checkCameraPermission();

      if (status.isGranted) {
        emit(TableScannerPermissionGranted());
        return;
      }

      // 2. Si no está concedido, solicitarlo
      final requestedStatus = await _repository.requestCameraPermission();

      if (requestedStatus.isGranted) {
        emit(TableScannerPermissionGranted());
      } else if (requestedStatus.isPermanentlyDenied) {
        emit(TableScannerPermissionDenied(isPermanentlyDenied: true));
      } else {
        emit(TableScannerPermissionDenied(isPermanentlyDenied: false));
      }
    } catch (e) {
      emit(TableScannerError('Error al solicitar permiso: $e'));
    }
  }

  void _onQrDetected(
    QrCodeDetected event,
    Emitter<TableScannerState> emit,
  ) {
    final raw = event.rawValue.trim();

    String? tableId;

    if (raw.contains('/table/')) {
      final parts = raw.split('/table/');
      if (parts.length > 1) {
        final possibleId = parts.last.split('?').first.trim();
        final match = RegExp(r'\d+').firstMatch(possibleId);
        if (match != null) {
          tableId = match.group(0);
        }
      }
    } else if (raw.startsWith('restaurantesaas://table/')) {
      final possibleId = raw.replaceFirst('restaurantesaas://table/', '').trim();
      final match = RegExp(r'\d+').firstMatch(possibleId);
      if (match != null) {
        tableId = match.group(0);
      }
    } else {
      final match = RegExp(r'\d+').firstMatch(raw);
      if (match != null) {
        tableId = match.group(0);
      }
    }

    if (tableId != null && tableId.isEmpty) {
      tableId = null;
    }

    print('[TableScannerBloc] QR Detectado: "$raw" -> tableId extraído: "$tableId"');

    emit(TableScannerQrDetected(rawValue: raw, tableId: tableId));

    if (tableId != null) {
      emit(TableScannerNavigating(tableId));
    }
  }

  void _onReset(ResetScanner event, Emitter<TableScannerState> emit) {
    emit(TableScannerPermissionGranted());
  }
}
