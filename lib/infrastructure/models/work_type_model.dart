class WorkTypeModel {
  int? id;
  String? name;
  String? description;
  String? createdAt;
  String? deletedAt;

  WorkTypeModel({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    this.deletedAt,
  });

  WorkTypeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    return data;
  }

  bool get isDeleted => deletedAt != null;
}