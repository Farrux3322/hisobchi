import 'package:hisobchi/infrastructure/common/network_provider.dart';

class ProjectRepository {
  Future<Map<String, dynamic>> get() async {
    final response = await dio.get('/project/projects',data: {
      'search':null
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getById({required int id}) async {
    final response = await dio.get('/project/project/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> create({required Object data}) async {
    final response = await dio.post('/project/project', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update({required Object data, required int id}) async {
    final response = await dio.put('/project/project/$id', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> delete({required int id}) async {
    final response = await dio.delete('project/project/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> restore({required int id}) async {
    final response = await dio.post('/project/project/$id/restore');
    return response.data;
  }

  Future<Map<String, dynamic>> forceDelete({required int id}) async {
    final response = await dio.delete('project/project/$id/force-delete');
    return response.data;
  }
}