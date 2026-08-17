import 'package:ehisob/infrastructure/common/network_provider.dart';

class ProjectReportRepository {
  Future<Map<String, dynamic>> getProjectReport({required int projectId}) async {
    final response = await dio.get('/reports/projects/balance?project_id=$projectId');
    return response.data;
  }
}
