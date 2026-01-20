// Partner Wallet Detail Response Model
class PartnerWalletDetailResponse {
  final bool status;
  final PartnerWalletDetail result;

  PartnerWalletDetailResponse({
    required this.status,
    required this.result,
  });

  factory PartnerWalletDetailResponse.fromJson(Map<String, dynamic> json) {
    return PartnerWalletDetailResponse(
      status: json['status'] ?? false,
      result: PartnerWalletDetail.fromJson(json['result'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.toJson(),
    };
  }
}

// Partner Wallet Detail Model
class PartnerWalletDetail {
  final int id;
  final int partnerId;
  final String partnerName;
  final int currencyTypeId;
  final String currencyTypeName;
  final String summa;
  final String? description;
  final List<TransactionFile> files;
  final String? returnDate;
  final String type;
  final int isCancelled;
  final String? cancelReason;
  final String createdAt;
  final String? deletedAt;

  PartnerWalletDetail({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.summa,
    this.description,
    required this.files,
    this.returnDate,
    required this.type,
    required this.isCancelled,
    this.cancelReason,
    required this.createdAt,
    this.deletedAt,
  });

  factory PartnerWalletDetail.fromJson(Map<String, dynamic> json) {
    return PartnerWalletDetail(
      id: json['id'] ?? 0,
      partnerId: json['partner_id'] ?? 0,
      partnerName: json['partner_name'] ?? '',
      currencyTypeId: json['currency_type_id'] ?? 0,
      currencyTypeName: json['currency_type_name'] ?? '',
      summa: json['summa']?.toString() ?? '0.00',
      description: json['description'],
      files: json['files'] != null
          ? (json['files'] as List)
              .map((file) => TransactionFile.fromJson(file))
              .toList()
          : [],
      returnDate: json['return_date'],
      type: json['type'] ?? '',
      isCancelled: json['is_cancelled'] ?? 0,
      cancelReason: json['cancel_reason'],
      createdAt: json['created_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partner_id': partnerId,
      'partner_name': partnerName,
      'currency_type_id': currencyTypeId,
      'currency_type_name': currencyTypeName,
      'summa': summa,
      'description': description,
      'files': files.map((file) => file.toJson()).toList(),
      'return_date': returnDate,
      'type': type,
      'is_cancelled': isCancelled,
      'cancel_reason': cancelReason,
      'created_at': createdAt,
      'deleted_at': deletedAt,
    };
  }

  // Helper methods
  double get amount => double.tryParse(summa) ?? 0.0;
  bool get isCredit => type == 'credit';
  bool get isDebt => type == 'debt';
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasFiles => files.isNotEmpty;
  bool get hasReturnDate => returnDate != null;
  bool get isCancelledBool => isCancelled == 1;

  String get typeDisplay {
    if (isCredit) return 'Kirim';
    if (isDebt) return 'Chiqim';
    return type;
  }
}

// Transaction File Model
class TransactionFile {
  final int id;
  final String url;

  TransactionFile({
    required this.id,
    required this.url,
  });

  factory TransactionFile.fromJson(Map<String, dynamic> json) {
    return TransactionFile(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}