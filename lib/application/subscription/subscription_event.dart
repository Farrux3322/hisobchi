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

  const PurchaseSubscriptionEvent({
    required this.planId,
    required this.billingCycle,
    required this.paymentMethod,
  });

  @override
  List<Object> get props => [planId, billingCycle, paymentMethod];
}

class ResetPurchaseStatusEvent extends SubscriptionEvent {}