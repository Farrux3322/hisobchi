class ContractModel {
  int? id;
  int? workTypeId;
  String? workTypeName;
  String? description;
  String? summa;
  List<ContractFileModel>? files;
  int? projectId;
  String? createdAt;
  String? deletedAt;
  String? activity;

  ContractModel({
    this.id,
    this.workTypeId,
    this.workTypeName,
    this.description,
    this.summa,
    this.files,
    this.projectId,
    this.createdAt,
    this.deletedAt,
    this.activity,
  });

  ContractModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workTypeId = json['work_type_id'];
    workTypeName = json['work_type_name'];
    description = json['description'];
    summa = json['summa']?.toString();
    if (json['files'] != null) {
      files = <ContractFileModel>[];
      json['files'].forEach((v) {
        files!.add(ContractFileModel.fromJson(v));
      });
    }
    projectId = json['project_id'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
    activity = json['activity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['work_type_id'] = workTypeId;
    data['work_type_name'] = workTypeName;
    data['description'] = description;
    data['summa'] = summa;
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    data['project_id'] = projectId;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    data['activity'] = activity;
    return data;
  }

  bool get isDeleted => deletedAt != null;

  String get formattedSumma {
    if (summa == null || summa!.isEmpty) return '0';
    final amount = int.tryParse(summa!) ?? 0;
    return _formatNumber(amount);
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final result = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result.write(' ');
      }
      result.write(str[i]);
    }

    return result.toString();
  }
}

class ContractFileModel {
  int? id;
  String? url;

  ContractFileModel({this.id, this.url});

  ContractFileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    return data;
  }
}