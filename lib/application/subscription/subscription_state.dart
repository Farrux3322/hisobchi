part of 'subscription_bloc.dart';

class SubscriptionState extends Equatable {
  final Status status;
  final Status detailStatus;
  final Status infoStatus;
  final Status purchaseStatus;
  final Status orderStatus;
  final Status smsStatus;
  final List<PricingPlanModel> pricingPlans;
  final List<SMSPricingModel> smsPricingPlans;
  final PricingPlanModel? pricingPlanDetail;
  final SubscriptionInfoModel? subscriptionInfo;
  final PurchaseSubscriptionResult? purchaseResult;
  final String errorMessage;

  const SubscriptionState({
    this.status = Status.pure,
    this.detailStatus = Status.pure,
    this.infoStatus = Status.pure,
    this.purchaseStatus = Status.pure,
    this.orderStatus = Status.pure,
    this.smsStatus = Status.pure,
    this.pricingPlans = const [],
    this.smsPricingPlans = const [],
    this.pricingPlanDetail,
    this.subscriptionInfo,
    this.purchaseResult,
    this.errorMessage = '',
  });

  SubscriptionState copyWith({
    Status? status,
    Status? detailStatus,
    Status? infoStatus,
    Status? purchaseStatus,
    Status? orderStatus,
    Status? smsStatus,
    List<PricingPlanModel>? pricingPlans,
    List<SMSPricingModel>? smsPricingPlans,
    PricingPlanModel? pricingPlanDetail,
    SubscriptionInfoModel? subscriptionInfo,
    PurchaseSubscriptionResult? purchaseResult,
    String? errorMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      detailStatus: detailStatus ?? this.detailStatus,
      infoStatus: infoStatus ?? this.infoStatus,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      smsStatus: smsStatus ?? this.smsStatus,
      pricingPlans: pricingPlans ?? this.pricingPlans,
      smsPricingPlans: smsPricingPlans ?? this.smsPricingPlans,
      pricingPlanDetail: pricingPlanDetail ?? this.pricingPlanDetail,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
      purchaseResult: purchaseResult ?? this.purchaseResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        detailStatus,
        infoStatus,
        purchaseStatus,
        orderStatus,
        smsStatus,
        pricingPlans,
        smsPricingPlans,
        pricingPlanDetail,
        subscriptionInfo,
        purchaseResult,
        errorMessage
      ];
}