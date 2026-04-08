// ─── Qarz (credit) due dates ────────────────────────────────────────────────

class QarzDueDatesResponse {
  final bool status;
  final QarzDueDatesResult result;

  const QarzDueDatesResponse({required this.status, required this.result});

  factory QarzDueDatesResponse.fromJson(Map<String, dynamic> json) {
    return QarzDueDatesResponse(
      status: json['status'] ?? false,
      result: QarzDueDatesResult.fromJson(json['result']),
    );
  }
}

class QarzDueDatesResult {
  final int currentPage;
  final List<QarzDueItem> data;
  final String? nextPageUrl;
  final int perPage;
  final int? from;
  final int? to;

  const QarzDueDatesResult({
    required this.currentPage,
    required this.data,
    this.nextPageUrl,
    required this.perPage,
    this.from,
    this.to,
  });

  bool get hasNextPage => nextPageUrl != null;

  factory QarzDueDatesResult.fromJson(Map<String, dynamic> json) {
    return QarzDueDatesResult(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => QarzDueItem.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'],
      perPage: json['per_page'] ?? 15,
      from: json['from'],
      to: json['to'],
    );
  }
}

class QarzDueItem {
  final int id;
  final int walletId;
  final int partnerId;
  final String partnerName;
  final String partnerPhone;
  final String? description;
  final String type;
  final String scheduledAmount;
  final String remainingAmount;
  final String paidAmount;
  final int currencyTypeId;
  final String currencyTypeName;
  final String dueDate;
  final int? daysOverdue;
  final int? daysLeft;
  final String status;
  final String createdAt;

  const QarzDueItem({
    required this.id,
    required this.walletId,
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    this.description,
    required this.type,
    required this.scheduledAmount,
    required this.remainingAmount,
    required this.paidAmount,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.dueDate,
    this.daysOverdue,
    this.daysLeft,
    required this.status,
    required this.createdAt,
  });

  factory QarzDueItem.fromJson(Map<String, dynamic> json) {
    return QarzDueItem(
      id: json['id'],
      walletId: json['wallet_id'],
      partnerId: json['partner_id'],
      partnerName: json['partner_name'] ?? '',
      partnerPhone: json['partner_phone'] ?? '',
      description: json['description'],
      type: json['type'] ?? '',
      scheduledAmount: json['scheduled_amount'] ?? '0',
      remainingAmount: json['remaining_amount'] ?? '0',
      paidAmount: json['paid_amount'] ?? '0',
      currencyTypeId: json['currency_type_id'] ?? 1,
      currencyTypeName: json['currency_type_name'] ?? 'UZS',
      dueDate: json['due_date'] ?? '',
      daysOverdue: json['days_overdue'],
      daysLeft: json['days_left'],
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

// ─── Installment due dates ───────────────────────────────────────────────────

class InstallmentDueDatesResponse {
  final bool status;
  final InstallmentDueDatesResult result;

  const InstallmentDueDatesResponse({required this.status, required this.result});

  factory InstallmentDueDatesResponse.fromJson(Map<String, dynamic> json) {
    return InstallmentDueDatesResponse(
      status: json['status'] ?? false,
      result: InstallmentDueDatesResult.fromJson(json['result']),
    );
  }
}

class InstallmentDueDatesResult {
  final int currentPage;
  final List<InstallmentDueItem> data;
  final String? nextPageUrl;
  final int perPage;
  final int? from;
  final int? to;

  const InstallmentDueDatesResult({
    required this.currentPage,
    required this.data,
    this.nextPageUrl,
    required this.perPage,
    this.from,
    this.to,
  });

  bool get hasNextPage => nextPageUrl != null;

  factory InstallmentDueDatesResult.fromJson(Map<String, dynamic> json) {
    return InstallmentDueDatesResult(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => InstallmentDueItem.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'],
      perPage: json['per_page'] ?? 15,
      from: json['from'],
      to: json['to'],
    );
  }
}

class InstallmentDueItem {
  final int id;
  final int itemNumber;
  final bool isAdvance;
  final String amount;
  final String paidAmount;
  final String remaining;
  final String dueDate;
  final String status;
  final String statusLabel;
  final int? daysOverdue;
  final int? daysLeft;
  final int planId;
  final int partnerId;
  final String partnerName;
  final String partnerPhone;
  final int currencyTypeId;
  final String currencyTypeName;
  final String planTotal;
  final String planPaid;
  final String planRemaining;
  final String planStatus;

  const InstallmentDueItem({
    required this.id,
    required this.itemNumber,
    required this.isAdvance,
    required this.amount,
    required this.paidAmount,
    required this.remaining,
    required this.dueDate,
    required this.status,
    required this.statusLabel,
    this.daysOverdue,
    this.daysLeft,
    required this.planId,
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.planTotal,
    required this.planPaid,
    required this.planRemaining,
    required this.planStatus,
  });

  factory InstallmentDueItem.fromJson(Map<String, dynamic> json) {
    return InstallmentDueItem(
      id: json['id'],
      itemNumber: json['item_number'] ?? 0,
      isAdvance: json['is_advance'] ?? false,
      amount: json['amount'] ?? '0',
      paidAmount: json['paid_amount'] ?? '0',
      remaining: json['remaining'] ?? '0',
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      daysOverdue: json['days_overdue'],
      daysLeft: json['days_left'],
      planId: json['plan_id'] ?? 0,
      partnerId: json['partner_id'] ?? 0,
      partnerName: json['partner_name'] ?? '',
      partnerPhone: json['partner_phone'] ?? '',
      currencyTypeId: json['currency_type_id'] ?? 1,
      currencyTypeName: json['currency_type_name'] ?? 'UZS',
      planTotal: json['plan_total'] ?? '0',
      planPaid: json['plan_paid'] ?? '0',
      planRemaining: json['plan_remaining'] ?? '0',
      planStatus: json['plan_status'] ?? '',
    );
  }
}
