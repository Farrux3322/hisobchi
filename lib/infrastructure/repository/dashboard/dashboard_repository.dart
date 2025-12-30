import 'package:hisobchi/infrastructure/common/network_provider.dart';

class DashboardRepository {
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await dio.get('/reports/dashboard');
    return response.data;
  }
}