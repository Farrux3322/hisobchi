import '../../common/network_provider.dart';
import '../../models/permission_model.dart';
import '../../models/staff_model.dart';

class StaffRepository {
  Future<PermissionListResponse> getPermissions() async {
    final response = await dio.get('/auth/staff/permissions');
    return PermissionListResponse.fromJson(response.data);
  }

  Future<Map<String, dynamic>> sendOtp({required String phone}) async {
    final response = await dio.post('/auth/staff/send-otp', data: {'phone': phone});
    return response.data;
  }

  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otpCode}) async {
    final response = await dio.post(
      '/auth/staff/verify-otp',
      data: {
        'phone': phone,
        'otp_code': otpCode,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createStaff({
    required String phone,
    required String verifyToken,
    required String name,
    required String password,
    required List<String> permissions,
  }) async {
    final response = await dio.post(
      '/auth/staff',
      data: {
        'phone': phone,
        'verify_token': verifyToken,
        'name': name,
        'password': password,
        'permissions': permissions,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateStaff({
    required int id,
    required bool isActive,
    required List<String> permissions,
  }) async {
    final response = await dio.put(
      '/auth/staff/$id',
      data: {
        'is_active': isActive,
        'permissions': permissions,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteStaff(int id) async {
    final response = await dio.delete('/auth/staff/$id');
    return response.data;
  }

  Future<StaffListResponse> getStaffList() async {
    final response = await dio.get('/auth/staff');
    return StaffListResponse.fromJson(response.data);
  }
}
