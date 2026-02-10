import '../dto/models/project/project_model.dart';

class ProjectIncomeModel {
  final int? id;
  final int? currencyTypeId;
  final String? currencyTypeName;
  final String? summa;
  final String? description;
  final List<ProjectFile>? files;
  final int? projectId;
  final String? createdAt;
  final String? deletedAt;

  ProjectIncomeModel({
    this.id,
    this.currencyTypeId,
    this.currencyTypeName,
    this.summa,
    this.description,
    this.files,
    this.projectId,
    this.createdAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null && deletedAt!.isNotEmpty;

  factory ProjectIncomeModel.fromJson(Map<String, dynamic> json) {
    return ProjectIncomeModel(
      id: json['id'],
      currencyTypeId: json['currency_type_id'],
      currencyTypeName: json['currency_type'],
      summa: json['summa']?.toString(),
      description: json['description'],
      files: json['files'] != null
          ? (json['files'] as List).map((e) => ProjectFile.fromJson(e)).toList()
          : null,
      projectId: json['project_id'],
      createdAt: json['created_at'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency_type_id': currencyTypeId,
      'currency_type': currencyTypeName,
      'summa': summa,
      'description': description,
      'files': files?.map((e) => e.toJson()).toList(),
      'project_id': projectId,
      'created_at': createdAt,
      'deleted_at': deletedAt,
    };
  }

  ProjectIncomeModel copyWith({
    int? id,
    int? currencyTypeId,
    String? currencyTypeName,
    String? summa,
    String? description,
    List<ProjectFile>? files,
    int? projectId,
    String? createdAt,
    String? deletedAt,
  }) {
    return ProjectIncomeModel(
      id: id ?? this.id,
      currencyTypeId: currencyTypeId ?? this.currencyTypeId,
      currencyTypeName: currencyTypeName ?? this.currencyTypeName,
      summa: summa ?? this.summa,
      description: description ?? this.description,
      files: files ?? this.files,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class ProjectIncomeListResponse {
  final bool status;
  final List<ProjectIncomeModel> incomes;
  final PaginationLinks? links;
  final PaginationMeta? meta;

  ProjectIncomeListResponse({
    required this.status,
    required this.incomes,
    this.links,
    this.meta,
  });

  factory ProjectIncomeListResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is Map<String, dynamic>) {
      return ProjectIncomeListResponse(
        status: json['status'] as bool,
        incomes: (result['data'] as List<dynamic>)
            .map((e) => ProjectIncomeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        links: result['links'] != null ? PaginationLinks.fromJson(result['links']) : null,
        meta: result['meta'] != null ? PaginationMeta.fromJson(result['meta']) : null,
      );
    }
    // Fallback for old direct list result
    return ProjectIncomeListResponse(
      status: json['status'] as bool,
      incomes: (result as List<dynamic>)
          .map((e) => ProjectIncomeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PaginationLinks {
  String? first;
  String? last;
  String? prev;
  String? next;

  PaginationLinks({this.first, this.last, this.prev, this.next});

  PaginationLinks.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    prev = json['prev'];
    next = json['next'];
  }
}

class PaginationMeta {
  int? currentPage;
  String? currentPageUrl;
  int? from;
  String? path;
  int? perPage;
  int? to;
  int? lastPage;

  PaginationMeta({
    this.currentPage,
    this.currentPageUrl,
    this.from,
    this.path,
    this.perPage,
    this.to,
    this.lastPage,
  });

  PaginationMeta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    currentPageUrl = json['current_page_url'];
    from = json['from'];
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    lastPage = json['last_page'];
  }
}