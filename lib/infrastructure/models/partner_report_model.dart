// Partner Report Main Response Model
class PartnerReportMainResponse {
  final bool status;
  final PartnerReportResult result;

  PartnerReportMainResponse({
    required this.status,
    required this.result,
  });

  factory PartnerReportMainResponse.fromJson(Map<String, dynamic> json) {
    return PartnerReportMainResponse(
      status: json['status'] ?? false,
      result: PartnerReportResult.fromJson(json['result'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.toJson(),
    };
  }
}

// Partner Report Result containing both UZS and USD data
class PartnerReportResult {
  final CurrencyReport uzs;
  final CurrencyReport usd;

  PartnerReportResult({
    required this.uzs,
    required this.usd,
  });

  factory PartnerReportResult.fromJson(Map<String, dynamic> json) {
    return PartnerReportResult(
      uzs: CurrencyReport.fromJson(json['UZS'] ?? {}),
      usd: CurrencyReport.fromJson(json['USD'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UZS': uzs.toJson(),
      'USD': usd.toJson(),
    };
  }
}

// Currency Report Model (UZS or USD)
class CurrencyReport {
  final String debt;
  final String credit;
  final String balance;
  final int partnersCount;
  final OperationCount operations;
  final CountType xaqdorlar;
  final CountType qarzdorlar;
  final CountType qarzExpired;
  final CountType qarz3Days;
  final CountType qarz7Days;

  CurrencyReport({
    required this.debt,
    required this.credit,
    required this.balance,
    required this.partnersCount,
    required this.operations,
    required this.xaqdorlar,
    required this.qarzdorlar,
    required this.qarzExpired,
    required this.qarz3Days,
    required this.qarz7Days,
  });

  factory CurrencyReport.fromJson(Map<String, dynamic> json) {
    return CurrencyReport(
      debt: json['debt']?.toString() ?? '0.00',
      credit: json['credit']?.toString() ?? '0.00',
      balance: json['balance']?.toString() ?? '0.00',
      partnersCount: json['partners_count'] ?? 0,
      operations: OperationCount.fromJson(json['operations'] ?? {}),
      xaqdorlar: CountType.fromJson(json['xaqdorlar'] ?? {}),
      qarzdorlar: CountType.fromJson(json['qarzdorlar'] ?? {}),
      qarzExpired: CountType.fromJson(json['qarz_expired'] ?? {}),
      qarz3Days: CountType.fromJson(json['qarz_today'] ?? {}),
      qarz7Days: CountType.fromJson(json['qarz_3_days'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'debt': debt,
      'credit': credit,
      'balance': balance,
      'partners_count': partnersCount,
      'operations': operations.toJson(),
      'xaqdorlar': xaqdorlar.toJson(),
      'qarzdorlar': qarzdorlar.toJson(),
      'qarz_expired': qarzExpired.toJson(),
      'qarz_today': qarz3Days.toJson(),
      'qarz_3_days': qarz7Days.toJson(),
    };
  }

  // Helper methods for parsing amounts
  double get debtAmount => double.tryParse(debt) ?? 0.0;
  double get creditAmount => double.tryParse(credit) ?? 0.0;
  double get balanceAmount => double.tryParse(balance) ?? 0.0;

  // Check if balance is negative (debt)
  bool get hasDebt => balanceAmount < 0;

  // Check if balance is positive (credit)
  bool get hasCredit => balanceAmount > 0;

  // Get formatted balance
  String get formattedBalance {
    final amount = balanceAmount.abs();
    return amount.toStringAsFixed(2);
  }
}

// Operation Count Model
class OperationCount {
  final int count;
  final String type;

  OperationCount({
    required this.count,
    required this.type,
  });

  factory OperationCount.fromJson(Map<String, dynamic> json) {
    return OperationCount(
      count: json['count'] ?? 0,
      type: json['type'] ?? 'oparation',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'type': type,
    };
  }
}

// Count Type Model (for xaqdorlar, qarzdorlar, qarz types)
class CountType {
  final int count;
  final String type;

  CountType({
    required this.count,
    required this.type,
  });

  factory CountType.fromJson(Map<String, dynamic> json) {
    return CountType(
      count: json['count'] ?? 0,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'type': type,
    };
  }
}