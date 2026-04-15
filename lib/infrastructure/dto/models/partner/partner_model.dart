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
  String? activity;
  PartnerBalance? balance;
  InstallmentRemaining? installmentRemaining;

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
    this.activity,
    this.balance,
    this.installmentRemaining,
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
    mainCurrencyTypeId =
        json['main_currency_type_id'] ?? json['currency_type_id'];
    mainCurrencyTypeName =
        json['main_currency_type_name'] ?? json['currency_type_name'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
    sendOnKirim = json['send_on_kirim'];
    sendOnChiqim = json['send_on_chiqim'];
    activity = json['activity'];
    balance = json['balance'] != null
        ? PartnerBalance.fromJson(json['balance'])
        : null;
    installmentRemaining = json['installment_remaining'] != null
        ? InstallmentRemaining.fromJson(json['installment_remaining'])
        : null;
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
    data['activity'] = activity;
    if (balance != null) {
      data['balance'] = balance!.toJson();
    }
    if (installmentRemaining != null) {
      data['installment_remaining'] = installmentRemaining!.toJson();
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

class InstallmentRemaining {
  num? uzs;
  num? usd;

  InstallmentRemaining({this.uzs, this.usd});

  InstallmentRemaining.fromJson(Map<String, dynamic> json) {
    uzs = json['UZS'];
    usd = json['USD'];
  }

  Map<String, dynamic> toJson() => {'UZS': uzs, 'USD': usd};

  bool get hasAnyValue => (uzs ?? 0) != 0 || (usd ?? 0) != 0;
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

  PaginationMeta({
    this.currentPage,
    this.currentPageUrl,
    this.from,
    this.path,
    this.perPage,
    this.to,
  });

  PaginationMeta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    currentPageUrl = json['current_page_url'];
    from = json['from'];
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
  }
}
