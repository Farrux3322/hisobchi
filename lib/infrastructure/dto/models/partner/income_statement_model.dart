class IncomeStatementModel {
  bool? status;
  Result? result;

  IncomeStatementModel({this.status, this.result});

  IncomeStatementModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class Result {
  AccountData? uzsAccount;
  AccountData? usdAccount;

  Result({this.uzsAccount, this.usdAccount});

  Result.fromJson(Map<String, dynamic> json) {
    uzsAccount = json['uzs_account'] != null
        ? AccountData.fromJson(json['uzs_account'])
        : null;
    usdAccount = json['usd_account'] != null
        ? AccountData.fromJson(json['usd_account'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (uzsAccount != null) {
      data['uzs_account'] = uzsAccount!.toJson();
    }
    if (usdAccount != null) {
      data['usd_account'] = usdAccount!.toJson();
    }
    return data;
  }
}

class AccountData {
  num? debt;
  num? credit;
  num? balance;

  AccountData({this.debt, this.credit, this.balance});

  AccountData.fromJson(Map<String, dynamic> json) {
    debt = json['debt'];
    credit = json['credit'];
    balance = json['balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['debt'] = debt;
    data['credit'] = credit;
    data['balance'] = balance;
    return data;
  }
}