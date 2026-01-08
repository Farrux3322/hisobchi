class ProjectIncomeDetailModel {
  final int? id;
  final int? currencyTypeId;
  final String? currencyType;
  final num? summa;
  final String? description;
  final List<String>? files;
  final int? projectId;
  final String? createdAt;

  ProjectIncomeDetailModel({
    this.id,
    this.currencyTypeId,
    this.currencyType,
    this.summa,
    this.description,
    this.files,
    this.projectId,
    this.createdAt,
  });

  factory ProjectIncomeDetailModel.fromJson(Map<String, dynamic> json) {
    num? parsedSumma;
    if (json['summa'] != null) {
      if (json['summa'] is num) {
        parsedSumma = json['summa'];
      } else if (json['summa'] is String) {
        parsedSumma = num.tryParse(json['summa']);
      }
    }

    return ProjectIncomeDetailModel(
      id: json['id'] as int?,
      currencyTypeId: json['currency_type_id'] as int?,
      currencyType: json['currency_type'] as String?,
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
      'currency_type_id': currencyTypeId,
      'currency_type': currencyType,
      'summa': summa,
      'description': description,
      'files': files,
      'project_id': projectId,
      'created_at': createdAt,
    };
  }
}
