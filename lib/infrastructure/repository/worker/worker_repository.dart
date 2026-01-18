import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hisobchi/infrastructure/models/worker_model.dart';

import '../../common/network_provider.dart';

class WorkerRepository {

  /// Extracts error message from DioException and stringifies validation errors
  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      final response = e.response;
      if (response != null && response.data != null) {
        final dynamic data = response.data;

        // If it's already a JSON string that contains 'errors', return as is
        if (data is String && data.contains('"errors"')) {
          return data;
        }

        // If it's a Map, use the helper to extract/encode
        if (data is Map<String, dynamic>) {
          return _extractMessageFromData(data);
        }

        // Fallback for other status 422 cases if data is somehow a Map but not caught
        if (response.statusCode == 422) {
          try {
            return jsonEncode(data);
          } catch (_) {}
        }

        return _extractMessageFromData(data);
      }
      return e.message ?? e.toString();
    }
    return e.toString();
  }

  /// Helper to extract message from response data Map
  /// Senior level: prioritize 'errors' for UI parsing
  String _extractMessageFromData(dynamic data) {
    if (data is Map<String, dynamic>) {
      // 1. Check for Laravel style "errors" map
      if (data.containsKey('errors') && data['errors'] != null) {
        final errors = data['errors'];
        // Only return JSON if errors actually have content
        if (errors is Map && errors.isNotEmpty) {
          return jsonEncode(data);
        }
      }

      // 2. Check for nested "error" object with "errors"
      if (data.containsKey('error') && data['error'] is Map) {
        final errorObj = data['error'] as Map<String, dynamic>;
        if (errorObj.containsKey('errors') && errorObj['errors'] != null) {
          return jsonEncode(errorObj);
        }
        if (errorObj.containsKey('message')) {
          return errorObj['message'].toString();
        }
      }

      // 3. Fallback to top-level "message"
      if (data.containsKey('message')) {
        return data['message'].toString();
      }

      // 4. Last resort: just encode the whole map
      return jsonEncode(data);
    }

    // If it's a string, try to see if it's JSON
    if (data is String) {
      if (data.startsWith('{') && data.contains('"errors"')) {
        return data;
      }
      return data;
    }

    return data.toString();
  }
  // Get project workers
  Future<WorkerListResponse> getProjectWorkers(int projectId) async {
    try {

      final response = await dio.get(
        '/project/project/$projectId/workers',
      );
      if (response.statusCode == 200) {
        return WorkerListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load project workers');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Get all workers
  Future<WorkerListResponse> getAllWorkers({required int projectId}) async {
    try {
      final response = await dio.get('/documents/workers',data: {
        'search':'',
        'worker_not_in_project_id':projectId,
      });

      if (response.statusCode == 200) {
        return WorkerListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load workers');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Create worker
  Future<void> createWorker({
    required String name,
    required String phone,
    String? additionalPhone,
    List<String>? fileIds,
    required int workerPositionId,
    String? description,
  }) async {
    try {
      final data = {
        'name': name,
        'phone': phone,
        'additional_phone': additionalPhone,
        'file_id': fileIds,
        'worker_position_id': workerPositionId,
        'description': description,
      };

      final response = await dio.post('/documents/worker', data: data);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create worker');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Update worker
  Future<void> updateWorker({
    required int workerId,
    required String name,
    required String phone,
    String? additionalPhone,
    List<String>? fileIds,
    required int workerPositionId,
    String? description,
  }) async {
    try {
      final data = {
        'name': name,
        'phone': phone,
        'additional_phone': additionalPhone,
        'file_id': fileIds,
        'worker_position_id': workerPositionId,
        'description': description,
      };

      final response = await dio.put('/documents/worker/$workerId', data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update worker');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Delete worker
  Future<void> deleteWorker(int workerId) async {
    try {
      final response = await dio.delete('/documents/worker/$workerId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete worker');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Restore worker
  Future<void> restoreWorker(int workerId) async {
    try {
      final response = await dio.post('/documents/worker/$workerId/restore');

      if (response.statusCode != 200) {
        throw Exception('Failed to restore worker');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Force delete worker
  Future<void> forceDeleteWorker(int workerId) async {
    try {
      final response = await dio.delete('/documents/worker/$workerId/force');

      if (response.statusCode != 200) {
        throw Exception('Failed to force delete worker');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Get worker positions
  Future<WorkerPositionListResponse> getWorkerPositions() async {
    try {
      final response = await dio.get('/documents/worker-positions',data: {
        'search':''
      });

      if (response.statusCode == 200) {
        return WorkerPositionListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load worker positions');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Create worker position
  Future<void> createWorkerPosition({
    required String name,
    String? description,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
      };

      final response = await dio.post('/documents/worker-position', data: data);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create worker position');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Delete worker position
  Future<void> deleteWorkerPosition(int positionId) async {
    try {
      final response = await dio.delete('/documents/worker-position/$positionId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete worker position');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Restore worker position
  Future<void> restoreWorkerPosition(int positionId) async {
    try {
      final response = await dio.post('/documents/worker-position/$positionId/restore');

      if (response.statusCode != 200) {
        throw Exception('Failed to restore worker position');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Force delete worker position
  Future<void> forceDeleteWorkerPosition(int positionId) async {
    try {
      final response = await dio.delete('/documents/worker-position/$positionId/force-delete');

      if (response.statusCode != 200) {
        throw Exception('Failed to force delete worker position');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Add worker to project
  Future<void> addWorkerToProject({
    required int workerId,
    required int projectId,
  }) async {
    try {
      final data = {
        'worker_id': workerId,
        'project_id': projectId,
      };

      final response = await dio.post('/project/worker-add-to-project', data: data);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add worker to project');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Add multiple workers to project
  Future<void> addWorkersToProject({
    required List<int> workerIds,
    required int projectId,
  }) async {
    try {
      final data = {
        'project_id': projectId,
        'worker_ids': workerIds,
      };

      final response = await dio.post('/project/worker-add-to-project', data: data);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add workers to project');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Remove worker from project
  Future<void> removeWorkerFromProject({
    required int workerId,
    required int projectId,
  }) async {
    try {
      final data = {
        'worker_id': workerId,
        'project_id': projectId,
      };

      final response = await dio.post('/project/worker-remove-from-project', data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to remove worker from project');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}