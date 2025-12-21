class ProjectIncomeModel {
  final int? id;
  final int? currencyTypeId;
  final String? currencyTypeName;
  final String? summa;
  final String? description;
  final List<String>? files;
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
      files: json['files'] != null ? List<String>.from(json['files']) : null,
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
      'files': files,
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
    List<String>? files,
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
  final List<ProjectIncomeModel> result;

  ProjectIncomeListResponse({
    required this.status,
    required this.result,
  });

  factory ProjectIncomeListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectIncomeListResponse(
      status: json['status'] as bool,
      result: (json['result'] as List<dynamic>)
          .map((e) => ProjectIncomeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}