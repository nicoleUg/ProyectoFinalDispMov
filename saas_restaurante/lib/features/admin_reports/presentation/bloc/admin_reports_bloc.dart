import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_report_data_usecase.dart';
import 'admin_reports_event.dart';
import 'admin_reports_state.dart';

class AdminReportsBloc extends Bloc<AdminReportsEvent, AdminReportsState> {
  final GetReportDataUseCase getReportDataUseCase;

  AdminReportsBloc({required this.getReportDataUseCase}) : super(AdminReportsInitial()) {
    on<LoadReportDataRequested>(_onLoadReportDataRequested);
  }

  Future<void> _onLoadReportDataRequested(
    LoadReportDataRequested event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(AdminReportsLoading());
    try {
      final reportData = await getReportDataUseCase.call(event.period);
      emit(AdminReportsLoaded(reportData: reportData, selectedPeriod: event.period));
    } catch (e) {
      emit(AdminReportsError('Error al cargar reporte: $e'));
    }
  }
}
