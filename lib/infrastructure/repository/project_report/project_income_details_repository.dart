import 'package:ehisob/infrastructure/common/network_provider.dart';

class ProjectIncomeDetailsRepository {
  Future<Map<String, dynamic>> getIncomeDetails({required int projectId}) async {
    final response = await dio.get('/reports/projects/income-details?project_id=$projectId');
    return response.data;
  }
}
