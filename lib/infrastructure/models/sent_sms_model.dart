class SentSmsModel {
  final int id;
  final String message;
  final String status;
  final String sentAt;

  SentSmsModel({
    required this.id,
    required this.message,
    required this.status,
    required this.sentAt,
  });

  factory SentSmsModel.fromJson(Map<String, dynamic> json) {
    return SentSmsModel(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      sentAt: json['sent_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'status': status,
      'sent_at': sentAt,
    };
  }
}

class SentSmsResponse {
  final bool status;
  final SentSmsData result;

  SentSmsResponse({
    required this.status,
    required this.result,
  });

  factory SentSmsResponse.fromJson(Map<String, dynamic> json) {
    return SentSmsResponse(
      status: json['status'] ?? false,
      result: SentSmsData.fromJson(json['result'] ?? {}),
    );
  }
}

class SentSmsData {
  final List<SentSmsModel> data;
  final SentSmsLinks links;
  final SentSmsMeta meta;

  SentSmsData({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory SentSmsData.fromJson(Map<String, dynamic> json) {
    return SentSmsData(
      data: (json['data'] as List? ?? [])
          .map((item) => SentSmsModel.fromJson(item))
          .toList(),
      links: SentSmsLinks.fromJson(json['links'] ?? {}),
      meta: SentSmsMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class SentSmsLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  SentSmsLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory SentSmsLinks.fromJson(Map<String, dynamic> json) {
    return SentSmsLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class SentSmsMeta {
  final int currentPage;
  final String? currentPageUrl;
  final int? from;
  final String? path;
  final int perPage;
  final int? to;

  SentSmsMeta({
    required this.currentPage,
    this.currentPageUrl,
    this.from,
    this.path,
    required this.perPage,
    this.to,
  });

  factory SentSmsMeta.fromJson(Map<String, dynamic> json) {
    return SentSmsMeta(
      currentPage: json['current_page'] ?? 1,
      currentPageUrl: json['current_page_url'],
      from: json['from'],
      path: json['path'],
      perPage: json['per_page'] ?? 20,
      to: json['to'],
    );
  }
}
