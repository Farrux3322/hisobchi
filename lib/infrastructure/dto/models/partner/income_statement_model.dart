class IncomeStatementModel {
  bool? status;
  Result? result;

  IncomeStatementModel({this.status, this.result});

  IncomeStatementModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result =
    json['result'] != null ? Result.fromJson(json['result']) : null;
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
  Debt? debt;
  Debt? credit;
  Debt? balance;

  Result({this.debt, this.credit, this.balance});

  Result.fromJson(Map<String, dynamic> json) {
    debt = json['debt'] != null ? Debt.fromJson(json['debt']) : null;
    credit = json['credit'] != null ? Debt.fromJson(json['credit']) : null;
    balance =
    json['balance'] != null ? Debt.fromJson(json['balance']) : null;
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

class Debt {
  num? uZS;
  num? uSD;

  Debt({this.uZS, this.uSD});

  Debt.fromJson(Map<String, dynamic> json) {
    uZS = json['UZS'];
    uSD = json['USD'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UZS'] = uZS;
    data['USD'] = uSD;
    return data;
  }
}