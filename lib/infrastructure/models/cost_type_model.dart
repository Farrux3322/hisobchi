class CostTypeModel {
  final int? id;
  final int? isWorkerJoin;
  final String? name;
  final String? description;
  final String? createdAt;
  final String? deletedAt;

  CostTypeModel({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    this.deletedAt,
    this.isWorkerJoin,
  });

  bool get isDeleted => deletedAt != null && deletedAt!.isNotEmpty;

  factory CostTypeModel.fromJson(Map<String, dynamic> json) {
    return CostTypeModel(
      id: json['id'] as int?,
      isWorkerJoin: json['is_worker_join'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_worker_join': isWorkerJoin,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'deleted_at': deletedAt,
    };
  }

  CostTypeModel copyWith({
    int? id,
    int? isWorkerJoin,
    String? name,
    String? description,
    String? createdAt,
    String? deletedAt,
  }) {
    return CostTypeModel(
      id: id ?? this.id,
      isWorkerJoin: isWorkerJoin ?? this.isWorkerJoin,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class CostTypeListResponse {
  final bool status;
  final List<CostTypeModel> result;

  CostTypeListResponse({
    required this.status,
    required this.result,
  });

  factory CostTypeListResponse.fromJson(Map<String, dynamic> json) {
    return CostTypeListResponse(
      status: json['status'] as bool,
      result: (json['result'] as List<dynamic>)
          .map((e) => CostTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}