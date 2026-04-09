// ─── Summary ──────────────────────────────────────────────────────────────────

class InstallmentSummaryModel {
  final int currencyTypeId;
  final String currencyTypeName;
  final int activePlans;
  final int completedPlans;
  final int cancelledPlans;
  final String totalGiven;
  final String totalPaid;
  final String totalRemaining;
  final String overdueAmount;

  const InstallmentSummaryModel({
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.activePlans,
    required this.completedPlans,
    required this.cancelledPlans,
    required this.totalGiven,
    required this.totalPaid,
    required this.totalRemaining,
    required this.overdueAmount,
  });

  factory InstallmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return InstallmentSummaryModel(
      currencyTypeId: json['currency_type_id'] ?? 1,
      currencyTypeName: json['currency_type_name'] ?? 'UZS',
      activePlans: json['active_plans'] ?? 0,
      completedPlans: json['completed_plans'] ?? 0,
      cancelledPlans: json['cancelled_plans'] ?? 0,
      totalGiven: json['total_given'] ?? '0',
      totalPaid: json['total_paid'] ?? '0',
      totalRemaining: json['total_remaining'] ?? '0',
      overdueAmount: json['overdue_amount'] ?? '0',
    );
  }
}

// ─── Partners ─────────────────────────────────────────────────────────────────

class InstallmentPartnersResponse {
  final List<InstallmentPartnerReportModel> data;
  final String? nextLink;
  final int currentPage;
  final int perPage;

  const InstallmentPartnersResponse({
    required this.data,
    this.nextLink,
    required this.currentPage,
    required this.perPage,
  });

  bool get hasNextPage => nextLink != null && nextLink!.isNotEmpty;

  factory InstallmentPartnersResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>;
    return InstallmentPartnersResponse(
      data: (result['data'] as List? ?? [])
          .map((e) => InstallmentPartnerReportModel.fromJson(e))
          .toList(),
      nextLink: result['links']?['next'],
      currentPage: result['meta']?['current_page'] ?? 1,
      perPage: result['meta']?['per_page'] ?? 20,
    );
  }
}

class InstallmentPartnerReportModel {
  final int partnerId;
  final String partnerName;
  final String partnerPhone;
  final int activePlans;
  final String totalGiven;
  final String totalPaid;
  final String totalRemaining;
  final String overdueAmount;
  final String? lastPaymentAt;

  const InstallmentPartnerReportModel({
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    required this.activePlans,
    required this.totalGiven,
    required this.totalPaid,
    required this.totalRemaining,
    required this.overdueAmount,
    this.lastPaymentAt,
  });

  factory InstallmentPartnerReportModel.fromJson(Map<String, dynamic> json) {
    return InstallmentPartnerReportModel(
      partnerId: json['partner_id'] ?? 0,
      partnerName: json['partner_name'] ?? '',
      partnerPhone: json['partner_phone'] ?? '',
      activePlans: json['active_plans'] ?? 0,
      totalGiven: json['total_given'] ?? '0',
      totalPaid: json['total_paid'] ?? '0',
      totalRemaining: json['total_remaining'] ?? '0',
      overdueAmount: json['overdue_amount'] ?? '0',
      lastPaymentAt: json['last_payment_at'],
    );
  }
}

// ─── Forecast ─────────────────────────────────────────────────────────────────

class InstallmentForecastModel {
  final int currencyTypeId;
  final String currencyTypeName;
  final int periodDays;
  final int itemsCount;
  final String expectedAmount;
  final int dueTodayCount;
  final int due3daysCount;

  const InstallmentForecastModel({
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.periodDays,
    required this.itemsCount,
    required this.expectedAmount,
    required this.dueTodayCount,
    required this.due3daysCount,
  });

  factory InstallmentForecastModel.fromJson(Map<String, dynamic> json) {
    return InstallmentForecastModel(
      currencyTypeId: json['currency_type_id'] ?? 1,
      currencyTypeName: json['currency_type_name'] ?? 'UZS',
      periodDays: json['period_days'] ?? 30,
      itemsCount: json['items_count'] ?? 0,
      expectedAmount: json['expected_amount'] ?? '0',
      dueTodayCount: json['due_today_count'] ?? 0,
      due3daysCount: json['due_3days_count'] ?? 0,
    );
  }
}

// ─── Risky Partners ───────────────────────────────────────────────────────────

class InstallmentRiskyPartnerModel {
  final int partnerId;
  final String partnerName;
  final String partnerPhone;
  final int riskScore;
  final String riskLevel; // 'low' | 'medium' | 'high'
  final int overdueItems;
  final String overdueAmount;
  final int avgDaysOverdue;
  final String totalRemaining;
  final String? lastPaymentAt;

  const InstallmentRiskyPartnerModel({
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    required this.riskScore,
    required this.riskLevel,
    required this.overdueItems,
    required this.overdueAmount,
    required this.avgDaysOverdue,
    required this.totalRemaining,
    this.lastPaymentAt,
  });

  factory InstallmentRiskyPartnerModel.fromJson(Map<String, dynamic> json) {
    return InstallmentRiskyPartnerModel(
      partnerId: json['partner_id'] ?? 0,
      partnerName: json['partner_name'] ?? '',
      partnerPhone: json['partner_phone'] ?? '',
      riskScore: json['risk_score'] ?? 0,
      riskLevel: json['risk_level'] ?? 'low',
      overdueItems: json['overdue_items'] ?? 0,
      overdueAmount: json['overdue_amount'] ?? '0',
      avgDaysOverdue: json['avg_days_overdue'] ?? 0,
      totalRemaining: json['total_remaining'] ?? '0',
      lastPaymentAt: json['last_payment_at'],
    );
  }
}

// ─── Recovery ─────────────────────────────────────────────────────────────────

class InstallmentRecoveryModel {
  final int currencyTypeId;
  final String currencyTypeName;
  final String totalGiven;
  final String totalCollected;
  final String totalRemaining;
  final String recoveryRate;
  final String overdueAmount;
  final String overdueRate;
  final String ratingLabel;
  final int activePlans;
  final int completedPlans;
  final RecoveryByItems byItems;

  const InstallmentRecoveryModel({
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.totalGiven,
    required this.totalCollected,
    required this.totalRemaining,
    required this.recoveryRate,
    required this.overdueAmount,
    required this.overdueRate,
    required this.ratingLabel,
    required this.activePlans,
    required this.completedPlans,
    required this.byItems,
  });

  factory InstallmentRecoveryModel.fromJson(Map<String, dynamic> json) {
    return InstallmentRecoveryModel(
      currencyTypeId: json['currency_type_id'] ?? 1,
      currencyTypeName: json['currency_type_name'] ?? 'UZS',
      totalGiven: json['total_given'] ?? '0',
      totalCollected: json['total_collected'] ?? '0',
      totalRemaining: json['total_remaining'] ?? '0',
      recoveryRate: json['recovery_rate'] ?? '0',
      overdueAmount: json['overdue_amount'] ?? '0',
      overdueRate: json['overdue_rate'] ?? '0',
      ratingLabel: json['rating_label'] ?? '',
      activePlans: json['active_plans'] ?? 0,
      completedPlans: json['completed_plans'] ?? 0,
      byItems: RecoveryByItems.fromJson(json['by_items'] ?? {}),
    );
  }
}

class RecoveryByItems {
  final int paid;
  final int partial;
  final int overdue;
  final int pending;

  const RecoveryByItems({
    required this.paid,
    required this.partial,
    required this.overdue,
    required this.pending,
  });

  int get total => paid + partial + overdue + pending;

  factory RecoveryByItems.fromJson(Map<String, dynamic> json) {
    return RecoveryByItems(
      paid: json['paid'] ?? 0,
      partial: json['partial'] ?? 0,
      overdue: json['overdue'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }
}

// ─── Monthly ──────────────────────────────────────────────────────────────────

class InstallmentMonthlyModel {
  final int currencyTypeId;
  final String currencyTypeName;
  final int year;
  final List<MonthDataModel> months;

  const InstallmentMonthlyModel({
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.year,
    required this.months,
  });

  double get maxAmount => months.fold(0.0, (max, m) {
        final v = double.tryParse(m.totalAmount) ?? 0;
        return v > max ? v : max;
      });

  factory InstallmentMonthlyModel.fromJson(Map<String, dynamic> json) {
    return InstallmentMonthlyModel(
      currencyTypeId: json['currency_type_id'] ?? 1,
      currencyTypeName: json['currency_type_name'] ?? 'UZS',
      year: json['year'] ?? DateTime.now().year,
      months: (json['months'] as List? ?? [])
          .map((e) => MonthDataModel.fromJson(e))
          .toList(),
    );
  }
}

class MonthDataModel {
  final int month;
  final String monthLabel;
  final int paymentsCount;
  final String totalAmount;

  const MonthDataModel({
    required this.month,
    required this.monthLabel,
    required this.paymentsCount,
    required this.totalAmount,
  });

  double get amount => double.tryParse(totalAmount) ?? 0;

  static const _uzLabels = [
    '', 'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
    'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek',
  ];

  String get uzLabel => month >= 1 && month <= 12 ? _uzLabels[month] : monthLabel;

  factory MonthDataModel.fromJson(Map<String, dynamic> json) {
    return MonthDataModel(
      month: json['month'] ?? 0,
      monthLabel: json['month_label'] ?? '',
      paymentsCount: json['payments_count'] ?? 0,
      totalAmount: json['total_amount'] ?? '0',
    );
  }
}
