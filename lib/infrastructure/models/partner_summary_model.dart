import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';

class PartnerSummaryResponse {
  final bool status;
  final PartnerSummaryResult result;

  PartnerSummaryResponse({
    required this.status,
    required this.result,
  });

  factory PartnerSummaryResponse.fromJson(Map<String, dynamic> json) {
    return PartnerSummaryResponse(
      status: json['status'] ?? false,
      result: PartnerSummaryResult.fromJson(json['result'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.toJson(),
    };
  }
}

class PartnerSummaryResult {
  final int currentPage;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final List<PartnerSummaryData> data;
  final int total;
  final int perPage;

  PartnerSummaryResult({
    required this.currentPage,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.data,
    required this.total,
    required this.perPage,
  });

  factory PartnerSummaryResult.fromJson(Map<String, dynamic> json) {
    return PartnerSummaryResult(
      currentPage: json['current_page'] ?? 1,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      data: (json['data'] as List? ?? [])
          .map((e) => PartnerSummaryData.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
      'data': data.map((v) => v.toJson()).toList(),
      'total': total,
      'per_page': perPage,
    };
  }
}

class PartnerSummaryData {
  final int id;
  final String name;
  final String phone;
  final String? additionalPhone;
  final List<PartnerFile> files;
  final int mainCurrencyTypeId;
  final String mainCurrencyTypeName;
  final String balance;
  final String createdAt;
  final String? deletedAt;

  PartnerSummaryData({
    required this.id,
    required this.name,
    required this.phone,
    this.additionalPhone,
    required this.files,
    required this.mainCurrencyTypeId,
    required this.mainCurrencyTypeName,
    required this.balance,
    required this.createdAt,
    this.deletedAt,
  });

  factory PartnerSummaryData.fromJson(Map<String, dynamic> json) {
    return PartnerSummaryData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      additionalPhone: json['additional_phone'],
      files: (json['files'] as List? ?? [])
          .map((v) => PartnerFile.fromJson(v))
          .toList(),
      mainCurrencyTypeId: json['main_currency_type_id'] ?? 0,
      mainCurrencyTypeName: json['main_currency_type_name'] ?? '',
      balance: json['balance'] ?? '0.00',
      createdAt: json['created_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'additional_phone': additionalPhone,
      // 'files': files.map((v) => v.toJson()).toList(),
      'main_currency_type_id': mainCurrencyTypeId,
      'main_currency_type_name': mainCurrencyTypeName,
      'balance': balance,
      'created_at': createdAt,
      'deleted_at': deletedAt,
    };
  }

  double get balanceDouble => double.tryParse(balance) ?? 0.0;
}

