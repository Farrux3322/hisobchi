class DashboardModel {
  bool? status;
  DashboardResult? result;

  DashboardModel({this.status, this.result});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result = json['result'] != null ? DashboardResult.fromJson(json['result']) : null;
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

class DashboardResult {
  int? totalPartnersCount;
  int? totalProjectsCount;
  DebtCreditBalance? totalDebtCreditPartners;
  int? partnersWithLatePaymentsCount;

  DashboardResult({
    this.totalPartnersCount,
    this.totalProjectsCount,
    this.totalDebtCreditPartners,
    this.partnersWithLatePaymentsCount,
  });

  DashboardResult.fromJson(Map<String, dynamic> json) {
    totalPartnersCount = json['total_partners_count'];
    totalProjectsCount = json['total_projects_count'];
    totalDebtCreditPartners = json['total_debt_credit_partners'] != null
        ? DebtCreditBalance.fromJson(json['total_debt_credit_partners'])
        : null;
    partnersWithLatePaymentsCount = json['partners_with_late_payments_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_partners_count'] = totalPartnersCount;
    data['total_projects_count'] = totalProjectsCount;
    if (totalDebtCreditPartners != null) {
      data['total_debt_credit_partners'] = totalDebtCreditPartners!.toJson();
    }
    data['partners_with_late_payments_count'] = partnersWithLatePaymentsCount;
    return data;
  }
}

class DebtCreditBalance {
  num? uzs;
  num? usd;

  DebtCreditBalance({this.uzs, this.usd});

  DebtCreditBalance.fromJson(Map<String, dynamic> json) {
    uzs = json['uzs'];
    usd = json['usd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uzs'] = uzs;
    data['usd'] = usd;
    return data;
  }
}