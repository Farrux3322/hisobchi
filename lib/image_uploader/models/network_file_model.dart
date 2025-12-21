import 'uploadable_image.dart';

class NetworkFileModel extends UploadableImage {
  @override
  final String id;
  final String url;
  final String fileName;

  NetworkFileModel({
    required this.id,
    required this.url,
    required this.fileName,
  });

  NetworkFileModel copyWith({
    String? id,
    String? url,
    String? fileName,
  }) {
    return NetworkFileModel(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
    );
  }

  @override
  String get path => url;

  @override
  bool get isNetwork => true;
}
