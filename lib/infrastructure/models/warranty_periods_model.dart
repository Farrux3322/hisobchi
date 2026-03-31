class WarrantyPeriodsResponse {
  final bool status;
  final WarrantyPeriodsResult result;

  WarrantyPeriodsResponse({
    required this.status,
    required this.result,
  });

  factory WarrantyPeriodsResponse.fromJson(Map<String, dynamic> json) {
    return WarrantyPeriodsResponse(
      status: json['status'] ?? false,
      result: WarrantyPeriodsResult.fromJson(json['result'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result.toJson(),
    };
  }
}

class WarrantyPeriodsResult {
  final WarrantyCurrencyPeriods? uzs;
  final WarrantyCurrencyPeriods? usd;

  WarrantyPeriodsResult({
    this.uzs,
    this.usd,
  });

  factory WarrantyPeriodsResult.fromJson(Map<String, dynamic> json) {
    return WarrantyPeriodsResult(
      uzs: json['UZS'] != null ? WarrantyCurrencyPeriods.fromJson(json['UZS']) : null,
      usd: json['USD'] != null ? WarrantyCurrencyPeriods.fromJson(json['USD']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (uzs != null) data['UZS'] = uzs!.toJson();
    if (usd != null) data['USD'] = usd!.toJson();
    return data;
  }
}

class WarrantyCurrencyPeriods {
  final WarrantyPeriodItem qarzExpired;
  final WarrantyPeriodItem qarzToday;
  final WarrantyPeriodItem qarz3Days;

  WarrantyCurrencyPeriods({
    required this.qarzExpired,
    required this.qarzToday,
    required this.qarz3Days,
  });

  factory WarrantyCurrencyPeriods.fromJson(Map<String, dynamic> json) {
    return WarrantyCurrencyPeriods(
      qarzExpired: WarrantyPeriodItem.fromJson(json['qarz_expired'] ?? {}),
      qarzToday: WarrantyPeriodItem.fromJson(json['qarz_today'] ?? {}),
      qarz3Days: WarrantyPeriodItem.fromJson(json['qarz_3_days'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qarz_expired': qarzExpired.toJson(),
      'qarz_today': qarzToday.toJson(),
      'qarz_3_days': qarz3Days.toJson(),
    };
  }
}

class WarrantyPeriodItem {
  final int count;
  final String type;

  WarrantyPeriodItem({
    required this.count,
    required this.type,
  });

  factory WarrantyPeriodItem.fromJson(Map<String, dynamic> json) {
    return WarrantyPeriodItem(
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
