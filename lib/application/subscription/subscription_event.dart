part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class GetPricingPlansEvent extends SubscriptionEvent {}

class GetPricingPlanDetailEvent extends SubscriptionEvent {
  final int id;

  const GetPricingPlanDetailEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GetSubscriptionInfoEvent extends SubscriptionEvent {}

class PurchaseSubscriptionEvent extends SubscriptionEvent {
  final int planId;
  final String billingCycle;
  final String paymentMethod;
  final String returnUrl;

  const PurchaseSubscriptionEvent({
    required this.planId,
    required this.billingCycle,
    required this.paymentMethod,
    required this.returnUrl,
  });

  @override
  List<Object> get props => [planId, billingCycle, paymentMethod, returnUrl];
}

class ResetPurchaseStatusEvent extends SubscriptionEvent {}

class CheckOrderStatusEvent extends SubscriptionEvent {
  final String orderNumber;

  const CheckOrderStatusEvent(this.orderNumber);

  @override
  List<Object> get props => [orderNumber];
}

class ResetOrderStatusEvent extends SubscriptionEvent {}