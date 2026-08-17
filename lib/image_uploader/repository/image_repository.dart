import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ehisob/image_uploader/models/network_image_model.dart';
import 'package:ehisob/infrastructure/common/network_provider.dart';

class ImageRepository {
  Future<NetworkImageModel> uploadImage(
    File file,
    String endPoint,
    void Function(int, int) onSendProgress,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    final response = await dio.post(
      endPoint,
      data: formData,
      onSendProgress: onSendProgress,
    );

    final url = response.data['result'];
    return NetworkImageModel(
      url: url,
      id: url,
    );
  }
}
