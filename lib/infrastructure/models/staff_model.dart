class StaffModel {
  final int id;
  final bool isActive;
  final int userId;
  final String name;
  final String phone;
  final List<String> permissions;
  final String createdAt;

  StaffModel({
    required this.id,
    required this.isActive,
    required this.userId,
    required this.name,
    required this.phone,
    required this.permissions,
    required this.createdAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as int,
      isActive: json['is_active'] as bool,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_active': isActive,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'permissions': permissions,
      'created_at': createdAt,
    };
  }
}

class StaffListResponse {
  final bool status;
  final List<StaffModel> result;

  StaffListResponse({
    required this.status,
    required this.result,
  });

  factory StaffListResponse.fromJson(Map<String, dynamic> json) {
    return StaffListResponse(
      status: json['status'] as bool,
      result: (json['result'] as List)
          .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
