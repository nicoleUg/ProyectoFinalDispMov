import 'package:equatable/equatable.dart';

abstract class AdminReportsEvent extends Equatable {
  const AdminReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportDataRequested extends AdminReportsEvent {
  final String period; // 'today', 'week', 'month'

  const LoadReportDataRequested({required this.period});

  @override
  List<Object?> get props => [period];
}
