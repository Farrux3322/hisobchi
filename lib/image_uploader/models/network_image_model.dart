import 'uploadable_image.dart';

class NetworkImageModel extends UploadableImage {
  @override
  final String id;
  final String url;
  final String? localPath;

  NetworkImageModel({
    required this.id,
    required this.url,
    this.localPath,
  });

  NetworkImageModel copyWith({
    String? id,
    String? url,
    String? localPath,
    bool? isUploading,
  }) {
    return NetworkImageModel(
      id: id ?? this.id,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
    );
  }

  @override
  String get path => url;

  @override
  bool get isNetwork => true;
}
