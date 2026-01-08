class ProjectCostDetailItemModel {
  final int? id;
  final int? costTypeId;
  final String? costTypeName;
  final int? workerId;
  final String? workerName;
  final int? currencyTypeId;
  final String? currencyType;
  final num? summa;
  final String? description;
  final List<String>? files;
  final int? projectId;
  final String? createdAt;

  ProjectCostDetailItemModel({
    this.id,
    this.costTypeId,
    this.costTypeName,
    this.workerId,
    this.workerName,
    this.currencyTypeId,
    this.currencyType,
    this.summa,
    this.description,
    this.files,
    this.projectId,
    this.createdAt,
  });

  factory ProjectCostDetailItemModel.fromJson(Map<String, dynamic> json) {
    num? parsedSumma;
    if (json['summa'] != null) {
      if (json['summa'] is num) {
        parsedSumma = json['summa'];
      } else if (json['summa'] is String) {
        parsedSumma = num.tryParse(json['summa']);
      }
    }

    return ProjectCostDetailItemModel(
      id: json['id'] as int?,
      costTypeId: json['cost_type_id'] as int?,
      costTypeName: json['cost_type_name'] as String?,
      workerId: json['worker_id'] as int?,
      workerName: json['worker_name'] as String?,
      currencyTypeId: json['currency_type_id'] as int?,
      currencyType: json['currency_type_name'] as String?, // Note: API might change field name slightly
      summa: parsedSumma,
      description: json['description'] as String?,
      files: json['files'] != null
          ? (json['files'] as List).map((e) => e.toString()).toList()
          : [],
      projectId: json['project_id'] as int?,
      createdAt: json['created_at'] as String?,
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
      'currency_type_name': currencyType,
      'summa': summa,
      'description': description,
      'files': files,
      'project_id': projectId,
      'created_at': createdAt,
    };
  }
}
