import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/models/project_cost_model.dart';
import '../../common/network_provider.dart';

class ProjectCostRepository {
  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }

  // Get project costs
  Future<ProjectCostListResponse> getProjectCosts(int projectId, {int? costTypeId, int? page, String search = ''}) async {
    try {
      final Map<String, dynamic> params = {
        'project_id': projectId,
        'search': search,
      };

      if (costTypeId != null) {
        params['cost_type_id'] = costTypeId;
      }

      if (page != null) {
        params['page'] = page;
      }

      final response = await dio.get('/project/project-costs', queryParameters: params);

      if (response.statusCode == 200) {
        return ProjectCostListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load project costs');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Create project cost
  Future<void> createProjectCost({
    required int costTypeId,
     int? workerId,
    required int currencyTypeId,
    required double summa,
    String? description,
    List<int>? fileId,
    required int projectId,
  }) async {
    try {
      final data = {
        'cost_type_id': costTypeId,
        'worker_id': workerId,
        'currency_type_id': currencyTypeId,
        'summa': summa,
        'description': description,
        'file_id': fileId,
        'project_id': projectId,
      };

      final response = await dio.post('/project/project-cost', data: data);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create project cost');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Update project cost
  Future<void> updateProjectCost({
    required int projectCostId,
    required int costTypeId,
     int? workerId,
    required int currencyTypeId,
    required double summa,
    String? description,
    List<int>? fileId,
    required int projectId,
  }) async {
    try {
      final data = {
        'cost_type_id': costTypeId,
        'worker_id': workerId,
        'currency_type_id': currencyTypeId,
        'summa': summa,
        'description': description,
        'file_id': fileId,
        'project_id': projectId,
      };

      final response = await dio.put('/project/project-cost/$projectCostId', data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update project cost');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Delete project cost
  Future<void> deleteProjectCost(int projectCostId) async {
    try {
      final response = await dio.delete('/project/project-cost/$projectCostId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete project cost');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Restore project cost
  Future<void> restoreProjectCost(int projectCostId) async {
    try {
      final response = await dio.post('/project/project-cost/$projectCostId/restore');

      if (response.statusCode != 200) {
        throw Exception('Failed to restore project cost');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Force delete project cost
  Future<void> forceDeleteProjectCost(int projectCostId) async {
    try {
      final response = await dio.delete('/project/project-cost/$projectCostId/force-delete');

      if (response.statusCode != 200) {
        throw Exception('Failed to force delete project cost');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}