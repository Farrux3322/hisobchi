import 'package:ehisob/infrastructure/common/network_provider.dart';

class ProjectCostDetailsRepository {
  Future<Map<String, dynamic>> getCostDetails({required int projectId, required int costTypeId}) async {
    final response = await dio.get('/reports/projects/cost-details?project_id=$projectId&cost_type_id=$costTypeId');
    return response.data;
  }
}
