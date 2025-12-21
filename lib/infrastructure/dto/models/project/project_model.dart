class ProjectModel {
  int? id;
  String? projectName;
  String? projectOwner;
  String? phone;
  String? address;
  String? location;
  List<String>? files;
  String? createdAt;
  String? deletedAt;
  ProjectAccounts? accounts;

  ProjectModel({
    this.id,
    this.projectName,
    this.projectOwner,
    this.phone,
    this.address,
    this.location,
    this.files,
    this.createdAt,
    this.deletedAt,
    this.accounts,
  });

  ProjectModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    projectName = json['project_name'];
    projectOwner = json['project_owner'];
    phone = json['phone'];
    address = json['address'];
    location = json['location'];
    files = json['files'] != null ? List<String>.from(json['files']) : [];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
    accounts = json['accounts'] != null ? ProjectAccounts.fromJson(json['accounts']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['project_name'] = projectName;
    data['project_owner'] = projectOwner;
    data['phone'] = phone;
    data['address'] = address;
    data['location'] = location;
    data['files'] = files;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    if (accounts != null) {
      data['accounts'] = accounts!.toJson();
    }
    return data;
  }
}

class ProjectAccounts {
  CurrencyAmount? debt;
  CurrencyAmount? credit;

  ProjectAccounts({this.debt, this.credit});

  ProjectAccounts.fromJson(Map<String, dynamic> json) {
    debt = json['debt'] != null ? CurrencyAmount.fromJson(json['debt']) : null;
    credit = json['credit'] != null ? CurrencyAmount.fromJson(json['credit']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (debt != null) {
      data['debt'] = debt!.toJson();
    }
    if (credit != null) {
      data['credit'] = credit!.toJson();
    }
    return data;
  }
}

class CurrencyAmount {
  num? uzs;
  num? usd;

  CurrencyAmount({this.uzs, this.usd});

  CurrencyAmount.fromJson(Map<String, dynamic> json) {
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