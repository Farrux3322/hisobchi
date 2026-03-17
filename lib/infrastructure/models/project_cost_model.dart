import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';

class ProjectCostModel {
  final int? id;
  final int? costTypeId;
  final String? costTypeName;
  final int? workerId;
  final String? workerName;
  final int? currencyTypeId;
  final String? currencyTypeName;
  final String? summa;
  final String? description;
  final List<ProjectFile>? files;
  final int? projectId;
  final String? createdAt;
  final String? deletedAt;
  final String? activity;

  ProjectCostModel({
    this.id,
    this.costTypeId,
    this.costTypeName,
    this.workerId,
    this.workerName,
    this.currencyTypeId,
    this.currencyTypeName,
    this.summa,
    this.description,
    this.files,
    this.projectId,
    this.createdAt,
    this.deletedAt,
    this.activity,
  });

  bool get isDeleted => deletedAt != null && deletedAt!.isNotEmpty;

  factory ProjectCostModel.fromJson(Map<String, dynamic> json) {
    return ProjectCostModel(
      id: json['id'] as int?,
      costTypeId: json['cost_type_id'] as int?,
      costTypeName: json['cost_type_name'] as String?,
      workerId: json['worker_id'] as int?,
      workerName: json['worker_name'] as String?,
      currencyTypeId: json['currency_type_id'] as int?,
      currencyTypeName: json['currency_type_name'] as String?,
      summa: json['summa']?.toString(),
      description: json['description'] as String?,
      files: json['files'] != null
          ? (json['files'] as List).map((e) => ProjectFile.fromJson(e)).toList()
          : null,
      projectId: json['project_id'] as int?,
      createdAt: json['created_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      activity: json['activity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cost_type_id': costTypeId,
      'cost_type_name': costTypeName,
      'worker_id': workerId,
      'worker_name': workerName,
      'currency_type_id': currencyTypeId,
      'currency_type_name': currencyTypeName,
      'summa': summa,
      'description': description,
      'files': files?.map((e) => e.toJson()).toList(),
      'project_id': projectId,
      'created_at': createdAt,
      'deleted_at': deletedAt,
      'activity': activity,
    };
  }

  ProjectCostModel copyWith({
    int? id,
    int? costTypeId,
    String? costTypeName,
    int? workerId,
    String? workerName,
    int? currencyTypeId,
    String? currencyTypeName,
    String? summa,
    String? description,
    List<ProjectFile>? files,
    int? projectId,
    String? createdAt,
    String? deletedAt,
  }) {
    return ProjectCostModel(
      id: id ?? this.id,
      costTypeId: costTypeId ?? this.costTypeId,
      costTypeName: costTypeName ?? this.costTypeName,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      currencyTypeId: currencyTypeId ?? this.currencyTypeId,
      currencyTypeName: currencyTypeName ?? this.currencyTypeName,
      summa: summa ?? this.summa,
      description: description ?? this.description,
      files: files ?? this.files,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      activity: activity ?? this.activity,
    );
  }
}

class ProjectCostListResponse {
  final bool status;
  final List<ProjectCostModel> costs;
  final PaginationLinks? links;
  final PaginationMeta? meta;

  ProjectCostListResponse({
    required this.status,
    required this.costs,
    this.links,
    this.meta,
  });

  factory ProjectCostListResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is Map<String, dynamic>) {
      return ProjectCostListResponse(
        status: json['status'] as bool,
        costs: (result['data'] as List<dynamic>)
            .map((e) => ProjectCostModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        links: result['links'] != null ? PaginationLinks.fromJson(result['links']) : null,
        meta: result['meta'] != null ? PaginationMeta.fromJson(result['meta']) : null,
      );
    }
    // Fallback for old direct list result
    return ProjectCostListResponse(
      status: json['status'] as bool,
      costs: (result as List<dynamic>)
          .map((e) => ProjectCostModel.fromJson(e as Map<String, dynamic>))
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