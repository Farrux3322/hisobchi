class StaffWorkerResponse {
  final bool status;
  final List<StaffWorkerModel> result;

  StaffWorkerResponse({
    required this.status,
    required this.result,
  });

  factory StaffWorkerResponse.fromJson(Map<String, dynamic> json) {
    return StaffWorkerResponse(
      status: json['status'] ?? false,
      result: (json['result'] as List?)
              ?.map((e) => StaffWorkerModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.map((e) => e.toJson()).toList(),
    };
  }
}

class StaffWorkerModel {
  final int id;
  final String name;
  final String role;
  final String debt; // as string from backend
  final String credit; // as string from backend
  final int operationsCount;

  StaffWorkerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.debt,
    required this.credit,
    required this.operationsCount,
  });

  factory StaffWorkerModel.fromJson(Map<String, dynamic> json) {
    return StaffWorkerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      debt: json['debt']?.toString() ?? '0',
      credit: json['credit']?.toString() ?? '0',
      operationsCount: json['operations_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'debt': debt,
      'credit': credit,
      'operations_count': operationsCount,
    };
  }
}
