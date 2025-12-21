import 'uploadable_image.dart';

class LocalImageModel extends UploadableImage {
  @override
  final String path;
  final int progress;
  final bool isUploading;

  LocalImageModel({
    required this.path,
    this.progress = 0,
    this.isUploading = false,
  });

  LocalImageModel copyWith({
    String? path,
    int? progress,
    bool? isUploading,
  }) {
    return LocalImageModel(
      path: path ?? this.path,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  String? get id => null;

  @override
  bool get isNetwork => false;
}
