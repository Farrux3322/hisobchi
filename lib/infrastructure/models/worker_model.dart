class WorkerModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? additionalPhone;
  final List<String>? files;
  final int? workerPositionId;
  final String? workerPositionName; // API dan string sifatida keladi
  final String? description;
  final String? createdAt;
  final String? deletedAt;
  final String? activity;

  WorkerModel({
    this.id,
    this.name,
    this.phone,
    this.additionalPhone,
    this.files,
    this.workerPositionId,
    this.workerPositionName,
    this.description,
    this.createdAt,
    this.deletedAt,
    this.activity,
  });

  bool get isDeleted => deletedAt != null && deletedAt!.isNotEmpty;

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      additionalPhone: json['additional_phone'] as String?,
      files: json['files'] != null ? List<String>.from(json['files']) : [],
      workerPositionId: json['worker_position_id'] as int?,
      workerPositionName: json['worker_position'] as String?, // String sifatida
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      activity: json['activity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'additional_phone': additionalPhone,
      'files': files,
      'worker_position_id': workerPositionId,
      'worker_position': workerPositionName,
      'description': description,
      'created_at': createdAt,
      'deleted_at': deletedAt,
      'activity': activity,
    };
  }

  WorkerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? additionalPhone,
    List<String>? files,
    int? workerPositionId,
    String? workerPositionName,
    String? description,
    String? createdAt,
    String? deletedAt,
    String? activity,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      additionalPhone: additionalPhone ?? this.additionalPhone,
      files: files ?? this.files,
      workerPositionId: workerPositionId ?? this.workerPositionId,
      workerPositionName: workerPositionName ?? this.workerPositionName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      activity: activity ?? this.activity,
    );
  }
}

class WorkerPositionModel {
  final int? id;
  final String? name;
  final String? description;
  final String? createdAt;
  final String? deletedAt;
  final String? activity;

  WorkerPositionModel({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    this.deletedAt,
    this.activity,
  });

  bool get isDeleted => deletedAt != null && deletedAt!.isNotEmpty;

  factory WorkerPositionModel.fromJson(Map<String, dynamic> json) {
    return WorkerPositionModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      activity: json['activity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'deleted_at': deletedAt,
      'activity': activity,
    };
  }

  WorkerPositionModel copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
    String? deletedAt,
    String? activity,
  }) {
    return WorkerPositionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      activity: activity ?? this.activity,
    );
  }
}

class WorkerListResponse {
  final bool status;
  final List<WorkerModel> result;

  WorkerListResponse({
    required this.status,
    required this.result,
  });

  factory WorkerListResponse.fromJson(Map<String, dynamic> json) {
    return WorkerListResponse(
      status: json['status'] as bool,
      result: (json['result'] as List<dynamic>)
          .map((e) => WorkerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WorkerPositionListResponse {
  final bool status;
  final List<WorkerPositionModel> result;

  WorkerPositionListResponse({
    required this.status,
    required this.result,
  });

  factory WorkerPositionListResponse.fromJson(Map<String, dynamic> json) {
    return WorkerPositionListResponse(
      status: json['status'] as bool,
      result: (json['result'] as List<dynamic>)
          .map((e) => WorkerPositionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}