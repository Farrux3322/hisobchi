import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/common/network_provider.dart';

class DocumentUploadRepository {
  /// Faylni serverga yuklaydi.
  /// [type] — 'image' yoki 'file'
  /// Qaytaradi: {id: int, url: String}
  Future<({int id, String url})> upload({
    required File file,
    required String type,
    required void Function(int percent) onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      'type': type,
    });

    final response = await dio.post(
      'files/upload',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress(((sent / total) * 100).round());
      },
    );

    final result = response.data['result'] as Map<String, dynamic>;
    return (id: result['id'] as int, url: result['url'] as String);
  }
}
