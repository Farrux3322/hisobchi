import 'package:ehisob/infrastructure/models/partner_report_model.dart';

class PartnerDetailsReportResponse {
  final bool status;
  final PartnerDetailsResult result;

  PartnerDetailsReportResponse({
    required this.status,
    required this.result,
  });

  factory PartnerDetailsReportResponse.fromJson(Map<String, dynamic> json) {
    return PartnerDetailsReportResponse(
      status: json['status'] ?? false,
      result: PartnerDetailsResult.fromJson(json['result'] ?? {}),
    );
  }
}

class PartnerDetailsResult {
  final PartnerDetailsCurrencyReport uzs;
  final PartnerDetailsCurrencyReport usd;

  PartnerDetailsResult({
    required this.uzs,
    required this.usd,
  });

  factory PartnerDetailsResult.fromJson(Map<String, dynamic> json) {
    return PartnerDetailsResult(
      uzs: PartnerDetailsCurrencyReport.fromJson(json['UZS'] ?? {}),
      usd: PartnerDetailsCurrencyReport.fromJson(json['USD'] ?? {}),
    );
  }
}

class PartnerDetailsCurrencyReport {
  final String balance;
  final String income;
  final String expense;
  final int operationsCount;
  final CountType qarzExpired;
  final CountType qarzToday;
  final CountType qarz3Days;
  final List<MonthlyStatModel> monthlyStatistics;
  final List<BalanceDynamicModel> balanceDynamics;

  PartnerDetailsCurrencyReport({
    required this.balance,
    required this.income,
    required this.expense,
    required this.operationsCount,
    required this.qarzExpired,
    required this.qarzToday,
    required this.qarz3Days,
    required this.monthlyStatistics,
    required this.balanceDynamics,
  });

  factory PartnerDetailsCurrencyReport.fromJson(Map<String, dynamic> json) {
    return PartnerDetailsCurrencyReport(
      balance: json['balance']?.toString() ?? '0.00',
      income: json['income']?.toString() ?? '0.00',
      expense: json['expense']?.toString() ?? '0.00',
      operationsCount: json['operations_count'] ?? 0,
      qarzExpired: CountType.fromJson(json['qarz_expired'] ?? {}),
      qarzToday: CountType.fromJson(json['qarz_today'] ?? {}),
      qarz3Days: CountType.fromJson(json['qarz_3_days'] ?? {}),
      monthlyStatistics: (json['monthly_statistics'] as List? ?? [])
          .map((e) => MonthlyStatModel.fromJson(e))
          .toList(),
      balanceDynamics: (json['balance_dynamics'] as List? ?? [])
          .map((e) => BalanceDynamicModel.fromJson(e))
          .toList(),
    );
  }

  double get balanceAmount => double.tryParse(balance) ?? 0.0;
  double get incomeAmount => double.tryParse(income) ?? 0.0;
  double get expenseAmount => double.tryParse(expense) ?? 0.0;
}

class MonthlyStatModel {
  final String month;
  final double income;
  final double expense;

  MonthlyStatModel({
    required this.month,
    required this.income,
    required this.expense,
  });

  factory MonthlyStatModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatModel(
      month: json['month'] ?? '',
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BalanceDynamicModel {
  final String date;
  final double balance;

  BalanceDynamicModel({
    required this.date,
    required this.balance,
  });

  factory BalanceDynamicModel.fromJson(Map<String, dynamic> json) {
    return BalanceDynamicModel(
      date: json['date'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
