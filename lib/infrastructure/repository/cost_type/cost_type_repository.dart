import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/models/cost_type_model.dart';
import '../../common/network_provider.dart';

class CostTypeRepository {
  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }

  // Get all cost types
  Future<CostTypeListResponse> getCostTypes() async {
    try {
      final response = await dio.get('/documents/cost-types', data: {
        'search': ''
      });

      if (response.statusCode == 200) {
        return CostTypeListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load cost types');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Create cost type
  Future<void> createCostType({
    required String name,
    String? description,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
      };

      final response = await dio.post('/documents/cost-type', data: data);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create cost type');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Update cost type
  Future<void> updateCostType({
    required int costTypeId,
    required String name,
    String? description,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
      };

      final response = await dio.put('/documents/cost-type/$costTypeId', data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update cost type');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Delete cost type
  Future<void> deleteCostType(int costTypeId) async {
    try {
      final response = await dio.delete('/documents/cost-type/$costTypeId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete cost type');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Restore cost type
  Future<void> restoreCostType(int costTypeId) async {
    try {
      final response = await dio.post('/documents/cost-type/$costTypeId/restore');

      if (response.statusCode != 200) {
        throw Exception('Failed to restore cost type');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Force delete cost type
  Future<void> forceDeleteCostType(int costTypeId) async {
    try {
      final response = await dio.delete('/documents/cost-type/$costTypeId/force-delete');

      if (response.statusCode != 200) {
        throw Exception('Failed to force delete cost type');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}