import 'package:hisobchi/infrastructure/common/network_provider.dart';

class TutorialRepository {
  Future<Map<String, dynamic>> getTutorials() async {
    final response = await dio.get('/reports/app/tutorials');
    return response.data;
  }
}
