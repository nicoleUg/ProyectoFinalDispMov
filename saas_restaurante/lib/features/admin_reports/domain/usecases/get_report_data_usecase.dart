import '../entities/report_data_entity.dart';
import '../repositories/admin_reports_repository.dart';

class GetReportDataUseCase {
  final AdminReportsRepository repository;

  GetReportDataUseCase(this.repository);

  Future<ReportDataEntity> call(String period) async {
    return await repository.getReportData(period);
  }
}
