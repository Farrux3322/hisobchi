import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/common/network_provider.dart';

class ProjectRepository {
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


  Future<Map<String, dynamic>> get({Map<String, dynamic>? params, int? page}) async {
    final Map<String, dynamic> queryParameters = params ?? {};
    if (page != null) {
      queryParameters['page'] = page;
    }
    final response = await dio.get('/project/projects', queryParameters: queryParameters);
    return response.data;
  }

  Future<Map<String, dynamic>> getById({required int id}) async {
    final response = await dio.get('/project/project/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> create({required Object data}) async {
    try {
      final response = await dio.post('/project/project', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> update({required Object data, required int id}) async {
    try {
      final response = await dio.put('/project/project/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
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

  Future<Map<String, dynamic>> updateStatus({required int id, required String status}) async {
    try {
      final response = await dio.put('/project/project/$id/update-status', data: {'status': status});
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}