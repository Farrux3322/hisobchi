import '../../common/network_provider.dart';

class NotificationRepository {
  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final response = await dio.get('/notifications', queryParameters: {'page': page});
    return response.data;
  }

  Future<Map<String, dynamic>> readAllNotifications() async {
    final response = await dio.post('/notifications/read-all');
    return response.data;
  }

  Future<Map<String, dynamic>> readNotification(int id) async {
    final response = await dio.post('/notifications/$id/mark-as-read');
    return response.data;
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    final response = await dio.get('/notifications/unread-count');
    return response.data;
  }
}
