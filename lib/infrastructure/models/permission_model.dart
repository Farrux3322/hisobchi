class PermissionModel {
  final String name;
  final String key;
  final String displayName;

  PermissionModel({
    required this.name,
    required this.key,
    required this.displayName,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      name: json['name'] as String,
      key: json['key'] as String,
      displayName: json['display_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'key': key,
      'display_name': displayName,
    };
  }
}

class PermissionGroupModel {
  final String category;
  final String label;
  final List<PermissionModel> permissions;

  PermissionGroupModel({
    required this.category,
    required this.label,
    required this.permissions,
  });

  factory PermissionGroupModel.fromJson(Map<String, dynamic> json) {
    return PermissionGroupModel(
      category: json['category'] as String,
      label: json['label'] as String,
      permissions: (json['permissions'] as List)
          .map((e) => PermissionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'label': label,
      'permissions': permissions.map((e) => e.toJson()).toList(),
    };
  }
}

class PermissionListResponse {
  final bool status;
  final List<PermissionGroupModel> result;

  PermissionListResponse({
    required this.status,
    required this.result,
  });

  factory PermissionListResponse.fromJson(Map<String, dynamic> json) {
    return PermissionListResponse(
      status: json['status'] as bool,
      result: (json['result'] as List)
          .map((e) => PermissionGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
