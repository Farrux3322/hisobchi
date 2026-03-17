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
  String? activity;
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
    this.activity,
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
    activity = json['activity'];
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
    data['activity'] = activity;
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