class PartnerModel {
  int? id;
  String? name;
  String? phone;
  String? additionalPhone;
  List<PartnerFile>? files;
  int? mainCurrencyTypeId;
  bool? sendOnKirim;
  bool? sendOnChiqim;
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
    this.sendOnChiqim,
    this.sendOnKirim,
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
    sendOnKirim = json['send_on_kirim'];
    sendOnChiqim = json['send_on_chiqim'];
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
    data['send_on_kirim'] = sendOnKirim;
    data['send_on_chiqim'] = sendOnChiqim;
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

class PaginationLinks {
  String? first;
  String? last;
  String? prev;
  String? next;

  PaginationLinks({this.first, this.last, this.prev, this.next});

  PaginationLinks.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    prev = json['prev'];
    next = json['next'];
  }
}

class PaginationMeta {
  int? currentPage;
  String? currentPageUrl;
  int? from;
  String? path;
  int? perPage;
  int? to;

  PaginationMeta({this.currentPage, this.currentPageUrl, this.from, this.path, this.perPage, this.to});

  PaginationMeta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    currentPageUrl = json['current_page_url'];
    from = json['from'];
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
  }
}
