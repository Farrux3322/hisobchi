class FileUploadResponse {
  final int id;
  final String url;

  FileUploadResponse({
    required this.id,
    required this.url,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return FileUploadResponse(
      id: result['id'] as int,
      url: result['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}