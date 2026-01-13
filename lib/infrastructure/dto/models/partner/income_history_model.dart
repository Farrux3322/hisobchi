class IncomeHistoryModel {
  bool? status;
  List<Result>? result;

  IncomeHistoryModel({this.status, this.result});

  IncomeHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  int? id;
  int? partnerId;
  String? partnerName;
  int? currencyTypeId;
  String? currencyTypeName;
  String? summa;
  String? description;
  List<IncomeFile>? files;
  String? returnDate;
  String? type;
  int? isCancelled;
  String? createdAt;
  String? deletedAt;

  Result(
      {this.id,
        this.partnerId,
        this.partnerName,
        this.currencyTypeId,
        this.currencyTypeName,
        this.summa,
        this.description,
        this.files,
        this.returnDate,
        this.type,
        this.isCancelled,
        this.createdAt,
        this.deletedAt});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    partnerId = json['partner_id'];
    partnerName = json['partner_name'];
    currencyTypeId = json['currency_type_id'];
    currencyTypeName = json['currency_type_name'];
    summa = json['summa'];
    description = json['description'];
    if (json['files'] != null) {
      files = <IncomeFile>[];
      json['files'].forEach((v) {
        files!.add(IncomeFile.fromJson(v));
      });
    }
    returnDate = json['return_date'];
    type = json['type'];
    isCancelled = json['is_cancelled'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['partner_id'] = partnerId;
    data['partner_name'] = partnerName;
    data['currency_type_id'] = currencyTypeId;
    data['currency_type_name'] = currencyTypeName;
    data['summa'] = summa;
    data['description'] = description;
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    data['return_date'] = returnDate;
    data['type'] = type;
    data['is_cancelled'] = isCancelled;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    return data;
  }
}

class IncomeFile {
  int? id;
  String? url;

  IncomeFile({this.id, this.url});

  IncomeFile.fromJson(Map<String, dynamic> json) {
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