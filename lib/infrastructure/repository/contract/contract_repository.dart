import 'package:hisobchi/infrastructure/common/network_provider.dart';

class ContractRepository {
  Future<Map<String, dynamic>> getContracts({
    required int projectId,
    String search = '',
  }) async {
    final response = await dio.get(
      '/project/project-contracts',
      data: {
        'project_id': projectId,
        'search': search,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createContract({required Object data}) async {
    final response = await dio.post('/project/project-contract', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateContract({
    required Object data,
    required int id,
  }) async {
    final response = await dio.put('/project/project-contract/$id', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> deleteContract({required int id}) async {
    final response = await dio.delete('/project/project-contract/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> restoreContract({required int id}) async {
    final response = await dio.post('/project/project-contract/$id/restore');
    return response.data;
  }

  Future<Map<String, dynamic>> forceDeleteContract({required int id}) async {
    final response = await dio.delete('/project/project-contract/$id/force-delete');
    return response.data;
  }
}