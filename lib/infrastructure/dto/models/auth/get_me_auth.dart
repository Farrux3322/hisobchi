class GetMeAuthModel {
  GetMeAuthModel({
    this.status,
    this.result,
  });

  final bool? status;
  final GetMeAuthModelResult? result;

  GetMeAuthModel copyWith({
    bool? status,
    GetMeAuthModelResult? result,
  }) {
    return GetMeAuthModel(
      status: status ?? this.status,
      result: result ?? this.result,
    );
  }

  factory GetMeAuthModel.fromJson(Map<String, dynamic> json) {
    return GetMeAuthModel(
      status: json["status"],
      result: json["result"] == null ? null : GetMeAuthModelResult.fromJson(json["result"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "result": result?.toJson(),
      };

  @override
  String toString() {
    return "$status, $result, ";
  }
}

class GetMeAuthModelResult {
  GetMeAuthModelResult(
      {
    this.roleId,
    this.image,
    this.name,
    this.isAdmin,
    this.phone,
    this.authorGuid,
    this.role,
    this.permissions,
  });

  final String? name;
  final String? authorGuid;
  final String? phone;
  final String? image;
  final bool? isAdmin;
  final List<int?>? roleId;
  final List<String>? role;
  final Map<String?, List<String?>?>? permissions;

  GetMeAuthModelResult copyWith({
    String? name,
    String? phone,
    String? authorGuid,
    bool? isAdmin,
    final String? image,
     List<int?>? roleId,
    List<String>? role,
    Map<String?, List<String?>?>? permissions,
  }) {
    return GetMeAuthModelResult(
      name: name ?? this.name,
      roleId: roleId??this.roleId,
      authorGuid: authorGuid??this.authorGuid,
      isAdmin: isAdmin??this.isAdmin,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      image: image ?? this.image,
      permissions: permissions ?? this.permissions,
    );
  }

  factory GetMeAuthModelResult.fromJson(Map<String, dynamic> json) {
    try {
      Map<String, List<String>> permissionsMap = {};

      if (json['permissions'] != null && json['permissions'] is List) {
        List<dynamic> permissionsList = json['permissions'];
        for (var item in permissionsList) {
          if (item is Map<String, dynamic>) {
            item.forEach((key, value) {
              if (value is List) {
                permissionsMap[key] = List<String>.from(value);
              }
            });
          }
        }
      }

      return GetMeAuthModelResult(
        name: json["name"] as String?,
        phone: json["phone"] as String?,
        image: json["image"] as String?,
        authorGuid: json["author_guid"] as String?,
        isAdmin: json["is_admin"] as bool?,
        role: json["role"] != null ? List<String>.from(json["role"].map((x) => x as String)) : null,
        roleId: json["role_id"] != null ? List<int?>.from(json["role_id"].map((x) => x as int?)) : null,
        permissions: permissionsMap.map(
          (key, value) => MapEntry<String?, List<String?>?>(key, value),
        ),
      );
    } catch (e) {
      return GetMeAuthModelResult(
        name: null,
        phone: null,
        role: null,
        permissions: null,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "image": image,
        "is_admin": isAdmin,
        "author_guid": authorGuid,
        "role": role,
        "role_id": roleId,
        "permissions": permissions != null
            ? permissions!
                .map(
                  (key, value) => MapEntry(key!, value!),
                )
                .entries
                .map((e) => {e.key: e.value})
                .toList()
            : [],
      };

  @override
  String toString() {
    return "Name: $name, Phone: $phone, Role: $role, Permissions: $permissions,  IsAdmin: $isAdmin, AuthorGuid: $authorGuid";
  }
}

class GetMeAuthModelPermission {
  GetMeAuthModelPermission({
    this.role,
    this.user,
    this.projectType,
    this.floor,
    this.room,
    this.customer,
    this.masterProfession,
    this.repairType,
    this.worker,
    this.project,
    this.projectFile,
  });

  final List<String>? role;
  final List<String>? user;
  final List<String>? projectType;
  final List<String>? floor;
  final List<String>? room;
  final List<String>? customer;
  final List<String>? masterProfession;
  final List<String>? repairType;
  final List<String>? worker;
  final List<String>? project;
  final List<String>? projectFile;

  GetMeAuthModelPermission copyWith({
    List<String>? role,
    List<String>? user,
    List<String>? projectType,
    List<String>? floor,
    List<String>? room,
    List<String>? customer,
    List<String>? masterProfession,
    List<String>? repairType,
    List<String>? worker,
    List<String>? project,
    List<String>? projectFile,
  }) {
    return GetMeAuthModelPermission(
      role: role ?? this.role,
      user: user ?? this.user,
      projectType: projectType ?? this.projectType,
      floor: floor ?? this.floor,
      room: room ?? this.room,
      customer: customer ?? this.customer,
      masterProfession: masterProfession ?? this.masterProfession,
      repairType: repairType ?? this.repairType,
      worker: worker ?? this.worker,
      project: project ?? this.project,
      projectFile: projectFile ?? this.projectFile,
    );
  }

  factory GetMeAuthModelPermission.fromJson(Map<String, dynamic> json) {
    return GetMeAuthModelPermission(
      role: json["role"] == null ? [] : List<String>.from(json["role"]!.map((x) => x)),
      user: json["user"] == null ? [] : List<String>.from(json["user"]!.map((x) => x)),
      projectType: json["project_type"] == null ? [] : List<String>.from(json["project_type"]!.map((x) => x)),
      floor: json["floor"] == null ? [] : List<String>.from(json["floor"]!.map((x) => x)),
      room: json["room"] == null ? [] : List<String>.from(json["room"]!.map((x) => x)),
      customer: json["customer"] == null ? [] : List<String>.from(json["customer"]!.map((x) => x)),
      masterProfession: json["master_profession"] == null ? [] : List<String>.from(json["master_profession"]!.map((x) => x)),
      repairType: json["repair_type"] == null ? [] : List<String>.from(json["repair_type"]!.map((x) => x)),
      worker: json["worker"] == null ? [] : List<String>.from(json["worker"]!.map((x) => x)),
      project: json["project"] == null ? [] : List<String>.from(json["project"]!.map((x) => x)),
      projectFile: json["project_file"] == null ? [] : List<String>.from(json["project_file"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        "role": role?.map((x) => x).toList(),
        "user": user?.map((x) => x).toList(),
        "project_type": projectType?.map((x) => x).toList(),
        "floor": floor?.map((x) => x).toList(),
        "room": room?.map((x) => x).toList(),
        "customer": customer?.map((x) => x).toList(),
        "master_profession": masterProfession?.map((x) => x).toList(),
        "repair_type": repairType?.map((x) => x).toList(),
        "worker": worker?.map((x) => x).toList(),
        "project": project?.map((x) => x).toList(),
        "project_file": projectFile?.map((x) => x).toList(),
      };

  @override
  String toString() {
    return "$role, $user, $projectType, $floor, $room, $customer, $masterProfession, $repairType, $worker, $project, $projectFile, ";
  }
}
