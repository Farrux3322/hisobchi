class ProjectModel {
  int? id;
  String? projectName;
  String? projectOwner;
  String? phone;
  String? address;
  String? location;
  List<ProjectFile>? files;
  String? status;
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
    this.status,
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
    if (json['files'] != null) {
      files = <ProjectFile>[];
      json['files'].forEach((v) {
        files!.add(ProjectFile.fromJson(v));
      });
    } else {
      files = [];
    }
    status = json['status'];
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
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    if (accounts != null) {
      data['accounts'] = accounts!.toJson();
    }
    return data;
  }
}

class ProjectFile {
  int? id;
  String? url;

  ProjectFile({this.id, this.url});

  ProjectFile.fromJson(Map<String, dynamic> json) {
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

class ProjectAccounts {
  CurrencyAmount? debt;
  CurrencyAmount? credit;
  CurrencyAmount? balance;

  ProjectAccounts({this.debt, this.credit, this.balance});

  ProjectAccounts.fromJson(Map<String, dynamic> json) {
    debt = json['debt'] != null ? CurrencyAmount.fromJson(json['debt']) : null;
    credit = json['credit'] != null ? CurrencyAmount.fromJson(json['credit']) : null;
    balance = json['balance'] != null ? CurrencyAmount.fromJson(json['balance']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (debt != null) {
      data['debt'] = debt!.toJson();
    }
    if (credit != null) {
      data['credit'] = credit!.toJson();
    }
    if (balance != null) {
      data['balance'] = balance!.toJson();
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