class ClientReportSectionOneResponse {
  final bool status;
  final List<ClientReportPartner> result;

  ClientReportSectionOneResponse({
    required this.status,
    required this.result,
  });

  factory ClientReportSectionOneResponse.fromJson(Map<String, dynamic> json) {
    return ClientReportSectionOneResponse(
      status: json['status'] ?? false,
      result: json['result'] != null
          ? (json['result'] as List).map((item) => ClientReportPartner.fromJson(item)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.map((item) => item.toJson()).toList(),
    };
  }
}

class ClientReportPartner {
  final int id;
  final String name;
  final String phone;
  final PartnerBalance balance;

  ClientReportPartner({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
  });

  factory ClientReportPartner.fromJson(Map<String, dynamic> json) {
    return ClientReportPartner(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      balance: PartnerBalance.fromJson(json['balance'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'balance': balance.toJson(),
    };
  }
}

class PartnerBalance {
  final double uzs;
  final double usd;

  PartnerBalance({
    required this.uzs,
    required this.usd,
  });

  factory PartnerBalance.fromJson(Map<String, dynamic> json) {
    return PartnerBalance(
      usd: double.parse((json['usd'] ?? json['USD'] ?? '0').toString()).toDouble(),
      uzs: double.parse((json['uzs'] ?? json['UZS'] ?? '0').toString()).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UZS': uzs,
      'USD': usd,
    };
  }

  // Calculate total balance in UZS (assuming USD to UZS rate if needed)
  double getTotalInUzs({double usdRate = 12500}) {
    return uzs + (usd * usdRate);
  }

  // Check if partner has debt (negative balance)
  bool hasDebt() {
    return uzs < 0 || usd < 0;
  }

  // Get balance status
  String getBalanceStatus() {
    if (uzs == 0 && usd == 0) return 'neutral';
    if (hasDebt()) return 'debt';
    return 'credit';
  }
}

// Section Two Models
class ClientReportSectionTwoResponse {
  final bool status;
  final PartnerDetailReport result;

  ClientReportSectionTwoResponse({
    required this.status,
    required this.result,
  });

  factory ClientReportSectionTwoResponse.fromJson(Map<String, dynamic> json) {
    return ClientReportSectionTwoResponse(
      status: json['status'] ?? false,
      result: PartnerDetailReport.fromJson(json['result'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.toJson(),
    };
  }
}

class PartnerDetailReport {
  final PartnerBalance initialBalance;
  final PartnerBalance periodDebits;
  final PartnerBalance periodCredits;
  final PartnerBalance finalBalance;

  PartnerDetailReport({
    required this.initialBalance,
    required this.periodDebits,
    required this.periodCredits,
    required this.finalBalance,
  });

  factory PartnerDetailReport.fromJson(Map<String, dynamic> json) {
    return PartnerDetailReport(
      initialBalance: PartnerBalance.fromJson(json['initial_balance'] ?? {}),
      periodDebits: PartnerBalance.fromJson(json['period_debits'] ?? {}),
      periodCredits: PartnerBalance.fromJson(json['period_credits'] ?? {}),
      finalBalance: PartnerBalance.fromJson(json['final_balance'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initial_balance': initialBalance.toJson(),
      'period_debits': periodDebits.toJson(),
      'period_credits': periodCredits.toJson(),
      'final_balance': finalBalance.toJson(),
    };
  }
}

// Section Three Models
class ClientReportSectionThreeResponse {
  final bool status;
  final List<PartnerTransaction> result;

  ClientReportSectionThreeResponse({
    required this.status,
    required this.result,
  });

  factory ClientReportSectionThreeResponse.fromJson(Map<String, dynamic> json) {
    return ClientReportSectionThreeResponse(
      status: json['status'] ?? false,
      result: json['result'] != null
          ? (json['result'] as List).map((item) => PartnerTransaction.fromJson(item)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.map((item) => item.toJson()).toList(),
    };
  }
}

class PartnerTransaction {
  final int id;
  final int partnerId;
  final String partnerName;
  final int currencyTypeId;
  final String currencyTypeName;
  final String summa;
  final String? description;
  final List<String> files;
  final String? returnDate;
  final String type;
  final int isCancelled;
  final String createdAt;
  final String? deletedAt;

  PartnerTransaction({
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
    required this.createdAt,
    this.deletedAt,
  });

  factory PartnerTransaction.fromJson(Map<String, dynamic> json) {
    return PartnerTransaction(
      id: json['id'] ?? 0,
      partnerId: json['partner_id'] ?? 0,
      partnerName: json['partner_name'] ?? '',
      currencyTypeId: json['currency_type_id'] ?? 0,
      currencyTypeName: json['currency_type_name'] ?? '',
      summa: json['summa']?.toString() ?? '0',
      description: json['description'],
      files: json['files'] != null ? List<String>.from(json['files']) : [],
      returnDate: json['return_date'],
      type: json['type'] ?? '',
      isCancelled: json['is_cancelled'] ?? 0,
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
      'files': files,
      'return_date': returnDate,
      'type': type,
      'is_cancelled': isCancelled,
      'created_at': createdAt,
      'deleted_at': deletedAt,
    };
  }

  double get amount => double.tryParse(summa) ?? 0.0;
}