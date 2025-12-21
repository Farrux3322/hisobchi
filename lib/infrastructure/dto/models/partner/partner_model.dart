class PartnerModel {
  int? id;
  String? name;
  String? phone;
  String? additionalPhone;
  List<String>? files;
  String? createdAt;
  String? deletedAt;

  PartnerModel(
      {this.id,
        this.name,
        this.phone,
        this.additionalPhone,
        this.files,
        this.createdAt,
        this.deletedAt});

  PartnerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    additionalPhone = json['additional_phone'];
    files = json['files'].cast<String>();
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['additional_phone'] = additionalPhone;
    data['files'] = files;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    return data;
  }
}
