class PartnerModel {
  int? id;
  String? name;
  String? phone;
  String? additionalPhone;
  List<PartnerFile>? files;
  int? mainCurrencyTypeId;
  String? mainCurrencyTypeName;
  String? createdAt;
  String? deletedAt;
  PartnerBalance? balance;

  PartnerModel({
    this.id,
    this.name,
    this.phone,
    this.additionalPhone,
    this.files,
    this.mainCurrencyTypeId,
    this.mainCurrencyTypeName,
    this.createdAt,
    this.deletedAt,
    this.balance,
  });

  PartnerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    additionalPhone = json['additional_phone'];
    if (json['files'] != null) {
      files = <PartnerFile>[];
      json['files'].forEach((v) {
        files!.add(PartnerFile.fromJson(v));
      });
    }
    mainCurrencyTypeId = json['main_currency_type_id'];
    mainCurrencyTypeName = json['main_currency_type_name'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
    balance = json['balance'] != null ? PartnerBalance.fromJson(json['balance']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['additional_phone'] = additionalPhone;
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    data['main_currency_type_id'] = mainCurrencyTypeId;
    data['main_currency_type_name'] = mainCurrencyTypeName;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    if (balance != null) {
      data['balance'] = balance!.toJson();
    }
    return data;
  }
}

class PartnerFile {
  int? id;
  String? url;

  PartnerFile({this.id, this.url});

  PartnerFile.fromJson(Map<String, dynamic> json) {
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

class PartnerBalance {
  num? uzs;
  num? usd;

  PartnerBalance({this.uzs, this.usd});

  PartnerBalance.fromJson(Map<String, dynamic> json) {
    uzs = json['UZS'];
    usd = json['USD'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UZS'] = uzs;
    data['USD'] = usd;
    return data;
  }
}
