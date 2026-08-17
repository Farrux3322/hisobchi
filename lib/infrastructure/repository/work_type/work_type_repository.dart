import 'package:ehisob/infrastructure/common/network_provider.dart';

class WorkTypeRepository {
  Future<Map<String, dynamic>> getAll() async {
    final response = await dio.get('/documents/work-types',data: {
      'search':''
    });
    return response.data;
  }

  Future<Map<String, dynamic>> create({required Object data}) async {
    final response = await dio.post('/documents/work-type', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update({required Object data, required int id}) async {
    final response = await dio.put('/documents/work-type/$id', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> delete({required int id}) async {
    final response = await dio.delete('/documents/work-type/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> restore({required int id}) async {
    final response = await dio.post('/documents/work-type/$id/restore');
    return response.data;
  }

  Future<Map<String, dynamic>> forceDelete({required int id}) async {
    final response = await dio.delete('/documents/work/$id/force-delete');
    return response.data;
  }
}