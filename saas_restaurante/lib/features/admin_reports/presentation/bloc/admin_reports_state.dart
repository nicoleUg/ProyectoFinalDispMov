import 'package:equatable/equatable.dart';
import '../../domain/entities/report_data_entity.dart';

abstract class AdminReportsState extends Equatable {
  const AdminReportsState();

  @override
  List<Object?> get props => [];
}

class AdminReportsInitial extends AdminReportsState {}

class AdminReportsLoading extends AdminReportsState {}

class AdminReportsLoaded extends AdminReportsState {
  final ReportDataEntity reportData;
  final String selectedPeriod;

  const AdminReportsLoaded({required this.reportData, required this.selectedPeriod});

  @override
  List<Object?> get props => [reportData, selectedPeriod];
}

class AdminReportsError extends AdminReportsState {
  final String error;

  const AdminReportsError(this.error);

  @override
  List<Object?> get props => [error];
}
