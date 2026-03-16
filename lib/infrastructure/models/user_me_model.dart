class UserMeModel {
  final bool status;
  final UserMeResult result;

  UserMeModel({
    required this.status,
    required this.result,
  });

  factory UserMeModel.fromJson(Map<String, dynamic> json) => UserMeModel(
        status: json["status"] ?? false,
        result: UserMeResult.fromJson(json["result"] ?? {}),
      );
}

class UserMeResult {
  final int userId;
  final int? workerId;
  final String name;
  final String? image;
  final String phone;
  final List<String> role;
  final List<String> permissions;
  final List<WorksFor> worksFor;
  final AppSettings appSettings;
  final bool xZiffler;

  UserMeResult({
    required this.userId,
    this.workerId,
    required this.name,
    this.image,
    required this.phone,
    required this.role,
    required this.permissions,
    required this.worksFor,
    required this.appSettings,
    required this.xZiffler,
  });

  factory UserMeResult.fromJson(Map<String, dynamic> json) => UserMeResult(
        userId: json["user_id"] ?? 0,
        workerId: json["worker_id"],
        name: json["name"] ?? "",
        image: json["image"],
        phone: json["phone"] ?? "",
        role: List<String>.from(json["role"] ?? []),
        permissions: List<String>.from(json["permissions"] ?? []),
        worksFor: List<WorksFor>.from((json["works_for"] as List? ?? []).map((x) => WorksFor.fromJson(x))),
        appSettings: AppSettings.fromJson(json["app_settings"] ?? {}),
        xZiffler: json["x_ziffler"] ?? false,
      );
}

class AppSettings {
  final String language;
  final String mode;
  final String? pincode;

  AppSettings({
    required this.language,
    required this.mode,
    this.pincode,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        language: json["language"] ?? "uz",
        mode: json["mode"] ?? "light",
        pincode: json["pincode"],
      );
}

class WorksFor {
  final int ownerId;
  final String ownerName;
  final String ownerPhone;
  final List<String> permissions;

  WorksFor({
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.permissions,
  });

  factory WorksFor.fromJson(Map<String, dynamic> json) => WorksFor(
        ownerId: json["owner_id"] ?? 0,
        ownerName: json["owner_name"] ?? "",
        ownerPhone: json["owner_phone"] ?? "",
        permissions: List<String>.from(json["permissions"] ?? []),
      );
}
