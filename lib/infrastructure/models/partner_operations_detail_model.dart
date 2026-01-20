// Partner Operations Detail Response Model
class PartnerOperationsDetailResponse {
  final bool status;
  final PartnerOperationsResult result;

  PartnerOperationsDetailResponse({
    required this.status,
    required this.result,
  });

  factory PartnerOperationsDetailResponse.fromJson(Map<String, dynamic> json) {
    return PartnerOperationsDetailResponse(
      status: json['status'] ?? false,
      result: PartnerOperationsResult.fromJson(json['result'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.toJson(),
    };
  }
}

// Partner Operations Result with Pagination
class PartnerOperationsResult {
  final int currentPage;
  final String currentPageUrl;
  final List<PartnerOperation> data;
  final String firstPageUrl;
  final int from;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;

  PartnerOperationsResult({
    required this.currentPage,
    required this.currentPageUrl,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
  });

  factory PartnerOperationsResult.fromJson(Map<String, dynamic> json) {
    return PartnerOperationsResult(
      currentPage: json['current_page'] ?? 1,
      currentPageUrl: json['current_page_url'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List).map((item) => PartnerOperation.fromJson(item)).toList()
          : [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 15,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'current_page_url': currentPageUrl,
      'data': data.map((item) => item.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
    };
  }

  // Helper getters
  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
  bool get isEmpty => data.isEmpty;
  int get totalItems => to;
}

// Partner Operation Model
class PartnerOperation {
  final int id;
  final int partnerId;
  final String partnerName;
  final String? partnerPhone;
  final String? description;
  final List<String> files;
  final String type;
  final String? scheduledAmount;
  final String remainingAmount;
  final String? paidAmount;
  final int currencyTypeId;
  final String currencyTypeName;
  final String? dueDate;
  final int? daysOverdue;
  final int? daysLeft;
  final String? status;
  final String createdAt;

  PartnerOperation({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    this.partnerPhone,
    this.description,
    this.files = const [],
    required this.type,
    this.scheduledAmount,
    required this.remainingAmount,
    this.paidAmount,
    required this.currencyTypeId,
    required this.currencyTypeName,
    this.dueDate,
    this.daysOverdue,
    this.daysLeft,
    this.status,
    required this.createdAt,
  });

  factory PartnerOperation.fromJson(Map<String, dynamic> json) {
    return PartnerOperation(
      id: json['id'] ?? 0,
      partnerId: json['partner_id'] ?? 0,
      partnerName: json['partner_name'] ?? '',
      partnerPhone: json['partner_phone'],
      description: json['description'],
      files: json['files'] != null
          ? List<String>.from(json['files'])
          : [],
      type: json['type'] ?? '',
      scheduledAmount: json['scheduled_amount']?.toString(),
      remainingAmount: json['remaining_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString(),
      currencyTypeId: json['currency_type_id'] ?? 0,
      currencyTypeName: json['currency_type_name'] ?? '',
      dueDate: json['due_date'],
      daysOverdue: json['days_overdue'],
      daysLeft: json['days_left'],
      status: json['status'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partner_id': partnerId,
      'partner_name': partnerName,
      'partner_phone': partnerPhone,
      'description': description,
      'files': files,
      'type': type,
      'scheduled_amount': scheduledAmount,
      'remaining_amount': remainingAmount,
      'paid_amount': paidAmount,
      'currency_type_id': currencyTypeId,
      'currency_type_name': currencyTypeName,
      'due_date': dueDate,
      'days_overdue': daysOverdue,
      'days_left': daysLeft,
      'status': status,
      'created_at': createdAt,
    };
  }

  // Helper methods
  double get amount => double.tryParse(remainingAmount) ?? 0.0;

  double get scheduledAmountValue => double.tryParse(scheduledAmount ?? '0') ?? 0.0;
  double get paidAmountValue => double.tryParse(paidAmount ?? '0') ?? 0.0;

  bool get isDebt => type.toLowerCase() == 'debt';
  bool get isCredit => type.toLowerCase() == 'credit';

  bool get isOverdue => daysOverdue != null && daysOverdue! > 0;
  bool get hasDueDate => dueDate != null && dueDate!.isNotEmpty;

  bool get hasReturnDate => hasDueDate;
  String? get returnDate => dueDate;

  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasFiles => files.isNotEmpty;

  String get typeDisplay {
    if (isDebt) return 'Kirim';
    if (isCredit) return 'Chiqim';
    return type;
  }

  String get statusDisplay {
    if (status == null || status!.isEmpty) return '';
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Kutilmoqda';
      case 'completed':
        return 'Yakunlangan';
      case 'cancelled':
        return 'Bekor qilingan';
      default:
        return status ?? '';
    }
  }
}