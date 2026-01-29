part of 'subscription_bloc.dart';

class SubscriptionState extends Equatable {
  final Status status;
  final Status detailStatus;
  final Status infoStatus;
  final Status purchaseStatus;
  final Status orderStatus;
  final List<PricingPlanModel> pricingPlans;
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
    this.pricingPlans = const [],
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
    List<PricingPlanModel>? pricingPlans,
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
      pricingPlans: pricingPlans ?? this.pricingPlans,
      pricingPlanDetail: pricingPlanDetail ?? this.pricingPlanDetail,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
      purchaseResult: purchaseResult ?? this.purchaseResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detailStatus, infoStatus, purchaseStatus, orderStatus, pricingPlans, pricingPlanDetail, subscriptionInfo, purchaseResult, errorMessage];
}