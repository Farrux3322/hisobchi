enum FileUploadStatus {
  initial,
  uploading,
  success,
  failure,
}

class FileUploadState {
  final FileUploadStatus status;
  final double progress;
  final int? uploadedFileId;
  final String? uploadedUrl;
  final String? errorMessage;

  const FileUploadState({
    this.status = FileUploadStatus.initial,
    this.progress = 0.0,
    this.uploadedFileId,
    this.uploadedUrl,
    this.errorMessage,
  });

  FileUploadState copyWith({
    FileUploadStatus? status,
    double? progress,
    int? uploadedFileId,
    String? uploadedUrl,
    String? errorMessage,
  }) {
    return FileUploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      uploadedFileId: uploadedFileId ?? this.uploadedFileId,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}