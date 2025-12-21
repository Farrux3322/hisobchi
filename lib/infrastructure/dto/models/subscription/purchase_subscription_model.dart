class PurchaseSubscriptionRequest {
  int? planId;
  String? billingCycle;
  String? paymentMethod;

  PurchaseSubscriptionRequest({
    this.planId,
    this.billingCycle,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['plan_id'] = planId;
    data['billing_cycle'] = billingCycle;
    data['payment_method'] = paymentMethod;
    return data;
  }
}

class PurchaseSubscriptionResult {
  int? subscriptionId;
  String? paymentUrl;
  String? amount;
  String? currency;

  PurchaseSubscriptionResult({
    this.subscriptionId,
    this.paymentUrl,
    this.amount,
    this.currency,
  });

  PurchaseSubscriptionResult.fromJson(Map<String, dynamic> json) {
    subscriptionId = json['subscription_id'];
    paymentUrl = json['payment_url'];
    amount = json['amount'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subscription_id'] = subscriptionId;
    data['payment_url'] = paymentUrl;
    data['amount'] = amount;
    data['currency'] = currency;
    return data;
  }
}

class PurchaseSubscriptionResponse {
  bool? status;
  PurchaseSubscriptionResult? result;
  String? message;

  PurchaseSubscriptionResponse({this.status, this.result, this.message});

  PurchaseSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result = json['result'] != null
        ? PurchaseSubscriptionResult.fromJson(json['result'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    data['message'] = message;
    return data;
  }
}