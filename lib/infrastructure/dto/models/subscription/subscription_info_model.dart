class SubscriptionInfoModel {
  bool? hasSubscription;
  SubscriptionDetail? subscription;

  SubscriptionInfoModel({this.hasSubscription, this.subscription});

  SubscriptionInfoModel.fromJson(Map<String, dynamic> json) {
    hasSubscription = json['has_subscription'];
    subscription = json['subscription'] != null
        ? SubscriptionDetail.fromJson(json['subscription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['has_subscription'] = hasSubscription;
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    return data;
  }
}

class SubscriptionDetail {
  int? id;
  PlanInfo? plan;
  String? status;
  String? statusLabel;
  String? billingCycle;
  CurrentPeriod? currentPeriod;
  String? nextBillingDate;
  num? daysUntilDue;
  bool? isOverdue;
  int? daysPastDue;
  Usage? usage;
  LastPayment? lastPayment;

  SubscriptionDetail({
    this.id,
    this.plan,
    this.status,
    this.statusLabel,
    this.billingCycle,
    this.currentPeriod,
    this.nextBillingDate,
    this.daysUntilDue,
    this.isOverdue,
    this.daysPastDue,
    this.usage,
    this.lastPayment,
  });

  SubscriptionDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    plan = json['plan'] != null ? PlanInfo.fromJson(json['plan']) : null;
    status = json['status'];
    statusLabel = json['status_label'];
    billingCycle = json['billing_cycle'];
    currentPeriod = json['current_period'] != null
        ? CurrentPeriod.fromJson(json['current_period'])
        : null;
    nextBillingDate = json['next_billing_date'];
    daysUntilDue = json['days_until_due']?.toDouble();
    isOverdue = json['is_overdue'];
    daysPastDue = json['days_past_due'];
    usage = json['usage'] != null ? Usage.fromJson(json['usage']) : null;
    lastPayment = json['last_payment'] != null
        ? LastPayment.fromJson(json['last_payment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (plan != null) {
      data['plan'] = plan!.toJson();
    }
    data['status'] = status;
    data['status_label'] = statusLabel;
    data['billing_cycle'] = billingCycle;
    if (currentPeriod != null) {
      data['current_period'] = currentPeriod!.toJson();
    }
    data['next_billing_date'] = nextBillingDate;
    data['days_until_due'] = daysUntilDue;
    data['is_overdue'] = isOverdue;
    data['days_past_due'] = daysPastDue;
    if (usage != null) {
      data['usage'] = usage!.toJson();
    }
    if (lastPayment != null) {
      data['last_payment'] = lastPayment!.toJson();
    }
    return data;
  }
}

class PlanInfo {
  int? id;
  String? name;
  String? displayName;

  PlanInfo({this.id, this.name, this.displayName});

  PlanInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    displayName = json['display_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['display_name'] = displayName;
    return data;
  }
}

class CurrentPeriod {
  String? start;
  String? end;

  CurrentPeriod({this.start, this.end});

  CurrentPeriod.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start'] = start;
    data['end'] = end;
    return data;
  }
}

class Usage {
  UsageDetail? customers;
  UsageDetail? projects;
  UsageDetail? users;
  SmsUsage? sms;

  Usage({this.customers, this.projects, this.users, this.sms});

  Usage.fromJson(Map<String, dynamic> json) {
    customers = json['customers'] != null
        ? UsageDetail.fromJson(json['customers'])
        : null;
    projects =
        json['projects'] != null ? UsageDetail.fromJson(json['projects']) : null;
    users = json['users'] != null ? UsageDetail.fromJson(json['users']) : null;
    sms = json['sms'] != null ? SmsUsage.fromJson(json['sms']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (customers != null) {
      data['customers'] = customers!.toJson();
    }
    if (projects != null) {
      data['projects'] = projects!.toJson();
    }
    if (users != null) {
      data['users'] = users!.toJson();
    }
    if (sms != null) {
      data['sms'] = sms!.toJson();
    }
    return data;
  }
}

class UsageDetail {
  int? current;
  dynamic max; // Can be int or "unlimited" string
  num? percentage;
  bool? canAdd;

  UsageDetail({this.current, this.max, this.percentage, this.canAdd});

  UsageDetail.fromJson(Map<String, dynamic> json) {
    current = json['current'];
    max = json['max']; // Keep as dynamic - can be int or string
    percentage = json['percentage'];
    canAdd = json['can_add'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current'] = current;
    data['max'] = max;
    data['percentage'] = percentage;
    data['can_add'] = canAdd;
    return data;
  }

  // Helper getter to check if unlimited
  bool get isUnlimited {
    if (max == null) return false;
    if (max is String) {
      return max.toString().toLowerCase() == 'unlimited';
    }
    return false;
  }

  // Helper getter to get max as int (returns -1 for unlimited)
  int get maxValue {
    if (max == null) return 0;
    if (max is int) return max;
    if (max is String && max.toString().toLowerCase() == 'unlimited') {
      return -1;
    }
    return int.tryParse(max.toString()) ?? 0;
  }
}

class SmsUsage {
  int? current;
  int? max;
  int? remaining;
  num? percentage;
  bool? canSend;

  SmsUsage({this.current, this.max, this.remaining, this.percentage, this.canSend});

  SmsUsage.fromJson(Map<String, dynamic> json) {
    current = json['current'];
    max = json['max'];
    remaining = json['remaining'];
    percentage = json['percentage'];
    canSend = json['can_send'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current'] = current;
    data['max'] = max;
    data['remaining'] = remaining;
    data['percentage'] = percentage;
    data['can_send'] = canSend;
    return data;
  }
}

class LastPayment {
  String? date;
  String? amount;
  String? method;

  LastPayment({this.date, this.amount, this.method});

  LastPayment.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    amount = json['amount'];
    method = json['method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['amount'] = amount;
    data['method'] = method;
    return data;
  }
}

class SubscriptionInfoResponse {
  bool? status;
  SubscriptionInfoModel? result;

  SubscriptionInfoResponse({this.status, this.result});

  SubscriptionInfoResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result = json['result'] != null
        ? SubscriptionInfoModel.fromJson(json['result'])
        : null;
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