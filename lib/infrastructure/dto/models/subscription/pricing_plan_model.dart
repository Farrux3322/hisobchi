class PricingPlanModel {
  int? id;
  String? name;
  String? displayName;
  String? description;
  PriceInfo? monthlyPrice;
  PriceInfo? semiAnnualPrice;
  PriceInfo? annualPrice;
  int? maxCustomers;
  int? maxProjects;
  int? maxUsers;
  int? smsPerMonth;
  PlanFeatures? features;
  List<String>? paymentMethods;
  bool? currentlySubscribed;
  bool? canSubscribe;
  List<DowngradeWarning>? downgradeWarnings;

  PricingPlanModel({
    this.id,
    this.name,
    this.displayName,
    this.description,
    this.monthlyPrice,
    this.semiAnnualPrice,
    this.annualPrice,
    this.maxCustomers,
    this.maxProjects,
    this.maxUsers,
    this.smsPerMonth,
    this.features,
    this.paymentMethods,
    this.currentlySubscribed,
    this.canSubscribe,
    this.downgradeWarnings,
  });

  PricingPlanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    displayName = json['display_name'];
    description = json['description'];
    monthlyPrice = json['monthly_price'] != null
        ? PriceInfo.fromJson(json['monthly_price'])
        : null;
    semiAnnualPrice = json['semi_annual_price'] != null
        ? PriceInfo.fromJson(json['semi_annual_price'])
        : null;
    annualPrice = json['annual_price'] != null
        ? PriceInfo.fromJson(json['annual_price'])
        : null;
    maxCustomers = json['max_customers'];
    maxProjects = json['max_projects'];
    maxUsers = json['max_users'];
    smsPerMonth = json['sms_per_month'];
    features = json['features'] != null
        ? PlanFeatures.fromJson(json['features'])
        : null;
    if (json['payment_methods'] != null) {
      paymentMethods = List<String>.from(json['payment_methods']);
    }
    currentlySubscribed = json['currently_subscribed'];
    canSubscribe = json['can_subscribe'];
    if (json['downgrade_warnings'] != null) {
      downgradeWarnings = <DowngradeWarning>[];
      json['downgrade_warnings'].forEach((v) {
        downgradeWarnings!.add(DowngradeWarning.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['display_name'] = displayName;
    data['description'] = description;
    if (monthlyPrice != null) {
      data['monthly_price'] = monthlyPrice!.toJson();
    }
    if (semiAnnualPrice != null) {
      data['semi_annual_price'] = semiAnnualPrice!.toJson();
    }
    if (annualPrice != null) {
      data['annual_price'] = annualPrice!.toJson();
    }
    data['max_customers'] = maxCustomers;
    data['max_projects'] = maxProjects;
    data['max_users'] = maxUsers;
    data['sms_per_month'] = smsPerMonth;
    if (features != null) {
      data['features'] = features!.toJson();
    }
    if (paymentMethods != null) {
      data['payment_methods'] = paymentMethods;
    }
    data['currently_subscribed'] = currentlySubscribed;
    data['can_subscribe'] = canSubscribe;
    if (downgradeWarnings != null) {
      data['downgrade_warnings'] =
          downgradeWarnings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PriceInfo {
  bool? currentlySubscribed;
  String? amount;
  String? formatted;
  dynamic discount;
  String? description;
  String? description1;

  PriceInfo({
    this.currentlySubscribed,
    this.amount,
    this.formatted,
    this.discount,
    this.description,
    this.description1,
  });

  PriceInfo.fromJson(Map<String, dynamic> json) {
    currentlySubscribed = json['currently_subscribed'];
    amount = json['amount'];
    formatted = json['formatted'];
    discount = json['discount'];
    description = json['description'];
    description1 = json['description1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currently_subscribed'] = currentlySubscribed;
    data['amount'] = amount;
    data['formatted'] = formatted;
    data['discount'] = discount;
    data['description'] = description;
    data['description1'] = description1;
    return data;
  }

  double get discountValue {
    if (discount == null) return 0;
    if (discount is String) {
      return double.tryParse(discount) ?? 0;
    }
    if (discount is num) {
      return discount.toDouble();
    }
    return 0;
  }
}

class DowngradeWarning {
  String? field;
  int? current;
  int? limit;
  String? message;

  DowngradeWarning({this.field, this.current, this.limit, this.message});

  DowngradeWarning.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    current = json['current'];
    limit = json['limit'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['field'] = field;
    data['current'] = current;
    data['limit'] = limit;
    data['message'] = message;
    return data;
  }
}

class PlanFeatures {
  bool? reports;
  bool? export;
  bool? fileUpload;

  PlanFeatures({
    this.reports,
    this.export,
    this.fileUpload,
  });

  PlanFeatures.fromJson(dynamic json) {
    if (json is String) {
      // Parse JSON string
      final Map<String, dynamic> featuresMap = _parseJsonString(json);
      reports = featuresMap['reports'];
      export = featuresMap['export'];
      fileUpload = featuresMap['file_upload'];
    } else if (json is Map<String, dynamic>) {
      reports = json['reports'];
      export = json['export'];
      fileUpload = json['file_upload'];
    }
  }

  Map<String, dynamic> _parseJsonString(String jsonString) {
    try {
      // Remove curly braces and parse
      final cleanString = jsonString.replaceAll('{', '').replaceAll('}', '');
      final Map<String, dynamic> result = {};

      final pairs = cleanString.split(',');
      for (var pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          final key = keyValue[0].replaceAll('"', '').trim();
          final value = keyValue[1].replaceAll('"', '').trim().toLowerCase();
          result[key] = value == 'true';
        }
      }
      return result;
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reports'] = reports;
    data['export'] = export;
    data['file_upload'] = fileUpload;
    return data;
  }
}

class PricingPlanResponse {
  bool? status;
  List<PricingPlanModel>? result;

  PricingPlanResponse({this.status, this.result});

  PricingPlanResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['result'] != null) {
      result = <PricingPlanModel>[];
      json['result'].forEach((v) {
        result!.add(PricingPlanModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PricingPlanDetailResponse {
  bool? status;
  PricingPlanModel? result;

  PricingPlanDetailResponse({this.status, this.result});

  PricingPlanDetailResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result = json['result'] != null ? PricingPlanModel.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}