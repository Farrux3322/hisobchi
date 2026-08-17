import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/common/network_provider.dart';
import 'package:ehisob/infrastructure/models/file_upload_response.dart';

class FileUploadRepository {
  /// Upload file to server and return the file id and URL
  ///
  /// [file] - File to upload
  /// [onProgress] - Callback for upload progress (0.0 to 100.0)
  ///
  /// Returns FileUploadResponse containing id and url
  Future<FileUploadResponse> uploadFile({
    required File file,
    required String type,
    required Function(double progress) onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'type':type
      });

      final response = await dio.post(
        '/files/upload',
        data: formData,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100);
          onProgress(progress);
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API dan response ni parse qilish
        return FileUploadResponse.fromJson(response.data);
      } else {
        throw Exception('File yuklashda xatolik: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Server xatosi: ${e.response?.statusMessage ?? e.message}');
      } else {
        throw Exception('Internet bilan bog\'liq muammo: ${e.message}');
      }
    } catch (e) {
      throw Exception('File yuklashda xatolik: $e');
    }
  }
}