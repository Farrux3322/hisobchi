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
    );
  }
}

class ProjectCostListResponse {
  final bool status;
  final List<ProjectCostModel> result;

  ProjectCostListResponse({
    required this.status,
    required this.result,
  });

  factory ProjectCostListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectCostListResponse(
      status: json['status'] as bool,
      result: (json['result'] as List<dynamic>)
          .map((e) => ProjectCostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}