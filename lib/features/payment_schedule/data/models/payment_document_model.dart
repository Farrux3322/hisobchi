import 'package:equatable/equatable.dart';

enum DocumentUploadStatus { idle, uploading, success, failure }

class PaymentDocumentModel extends Equatable {
  final String localPath;
  final String fileName;
  final bool isImage;
  final int? sizeBytes;

  final DocumentUploadStatus status;
  final int progress; // 0–100
  final int? serverId;
  final String? serverUrl;
  final String? errorMessage;

  const PaymentDocumentModel({
    required this.localPath,
    required this.fileName,
    required this.isImage,
    this.sizeBytes,
    this.status = DocumentUploadStatus.idle,
    this.progress = 0,
    this.serverId,
    this.serverUrl,
    this.errorMessage,
  });

  bool get isUploading => status == DocumentUploadStatus.uploading;
  bool get isUploaded => status == DocumentUploadStatus.success;
  bool get hasFailed => status == DocumentUploadStatus.failure;

  String get sizeLabel {
    if (sizeBytes == null) return '';
    if (sizeBytes! < 1024) return '$sizeBytes B';
    if (sizeBytes! < 1024 * 1024) return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  PaymentDocumentModel copyWith({
    DocumentUploadStatus? status,
    int? progress,
    int? serverId,
    String? serverUrl,
    String? errorMessage,
  }) {
    return PaymentDocumentModel(
      localPath: localPath,
      fileName: fileName,
      isImage: isImage,
      sizeBytes: sizeBytes,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      serverId: serverId ?? this.serverId,
      serverUrl: serverUrl ?? this.serverUrl,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [localPath, fileName, isImage, sizeBytes, status, progress, serverId, serverUrl, errorMessage];
}
