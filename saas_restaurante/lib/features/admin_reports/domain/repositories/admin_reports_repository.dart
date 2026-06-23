import '../entities/report_data_entity.dart';

abstract class AdminReportsRepository {
  Future<ReportDataEntity> getReportData(String period);
}
