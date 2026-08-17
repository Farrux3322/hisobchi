import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/models/project_income_model.dart';
import '../../common/network_provider.dart';

class ProjectIncomeRepository {
  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }

  // Get project incomes
  Future<ProjectIncomeListResponse> getProjectIncomes(int projectId, {int? page, String search = ''}) async {
    try {
      final Map<String, dynamic> params = {
        'project_id': projectId,
        'search': search,
      };
      if (page != null) {
        params['page'] = page;
      }

      final response = await dio.get('/project/project-incomes', queryParameters: params);

      if (response.statusCode == 200) {
        return ProjectIncomeListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load project incomes');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Create project income
  Future<void> createProjectIncome({
    required int currencyTypeId,
    required double summa,
    String? description,
    List<int>? fileId,
    required int projectId,
  }) async {
    try {
      final data = {
        'currency_type_id': currencyTypeId,
        'summa': summa,
        'description': description,
        'file_id': fileId,
        'project_id': projectId,
      };

      final response = await dio.post('/project/project-income', data: data);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create project income');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Update project income
  Future<void> updateProjectIncome({
    required int projectIncomeId,
    required int currencyTypeId,
    required double summa,
    String? description,
    List<int>? fileId,
    required int projectId,
  }) async {
    try {
      final data = {
        'currency_type_id': currencyTypeId,
        'summa': summa,
        'description': description,
        'file_id': fileId,
        'project_id': projectId,
      };

      final response = await dio.put('/project/project-income/$projectIncomeId', data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update project income');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Delete project income
  Future<void> deleteProjectIncome(int projectIncomeId) async {
    try {
      final response = await dio.delete('/project/project-income/$projectIncomeId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete project income');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Restore project income
  Future<void> restoreProjectIncome(int projectIncomeId) async {
    try {
      final response = await dio.post('/project/project-income/$projectIncomeId/restore');

      if (response.statusCode != 200) {
        throw Exception('Failed to restore project income');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Force delete project income
  Future<void> forceDeleteProjectIncome(int projectIncomeId) async {
    try {
      final response = await dio.delete('/project/project-income/$projectIncomeId/force-delete');

      if (response.statusCode != 200) {
        throw Exception('Failed to force delete project income');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}