class TimeReportSummaryResponse {
  final bool status;
  final TimeReportSummaryResult result;

  TimeReportSummaryResponse({
    required this.status,
    required this.result,
  });

  factory TimeReportSummaryResponse.fromJson(Map<String, dynamic> json) {
    return TimeReportSummaryResponse(
      status: json['status'] ?? false,
      result: TimeReportSummaryResult.fromJson(json['result'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.toJson(),
    };
  }
}

class TimeReportSummaryResult {
  final TimeCurrencySummary uzs;
  final TimeCurrencySummary usd;

  TimeReportSummaryResult({
    required this.uzs,
    required this.usd,
  });

  factory TimeReportSummaryResult.fromJson(Map<String, dynamic> json) {
    return TimeReportSummaryResult(
      uzs: TimeCurrencySummary.fromJson(json['UZS'] ?? {}),
      usd: TimeCurrencySummary.fromJson(json['USD'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UZS': uzs.toJson(),
      'USD': usd.toJson(),
    };
  }
}

class TimeCurrencySummary {
  final String debt;
  final String credit;

  TimeCurrencySummary({
    required this.debt,
    required this.credit,
  });

  factory TimeCurrencySummary.fromJson(Map<String, dynamic> json) {
    return TimeCurrencySummary(
      debt: json['debt']?.toString() ?? '0.00',
      credit: json['credit']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'debt': debt,
      'credit': credit,
    };
  }

  double get debtAmount => double.tryParse(debt) ?? 0.0;
  double get creditAmount => double.tryParse(credit) ?? 0.0;
}
