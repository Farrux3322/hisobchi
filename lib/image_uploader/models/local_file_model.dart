import 'uploadable_image.dart';

class LocalFileModel extends UploadableImage {
  @override
  final String path;
  final int progress;
  final bool isUploading;
  final String fileName;

  LocalFileModel({
    required this.path,
    required this.fileName,
    this.progress = 0,
    this.isUploading = false,
  });

  LocalFileModel copyWith({
    String? path,
    String? fileName,
    int? progress,
    bool? isUploading,
  }) {
    return LocalFileModel(
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  String? get id => null;

  @override
  bool get isNetwork => false;
}
