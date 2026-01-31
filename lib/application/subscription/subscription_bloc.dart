import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/subscription/pricing_plan_model.dart';
import 'package:hisobchi/infrastructure/dto/models/subscription/purchase_subscription_model.dart';
import 'package:hisobchi/infrastructure/dto/models/subscription/sms_pricing_model.dart';
import 'package:hisobchi/infrastructure/dto/models/subscription/subscription_info_model.dart';
import 'package:hisobchi/infrastructure/repository/subscription/subscription_repository.dart';

part 'subscription_event.dart';

part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final _repo = SubscriptionRepository();

  SubscriptionBloc() : super(const SubscriptionState()) {
    on<GetPricingPlansEvent>(getPricingPlans);
    on<GetPricingPlanDetailEvent>(getPricingPlanDetail);
    on<GetSubscriptionInfoEvent>(getSubscriptionInfo);
    on<PurchaseSubscriptionEvent>(purchaseSubscription);
    on<ResetPurchaseStatusEvent>(resetPurchaseStatus);
    on<CheckOrderStatusEvent>(checkOrderStatus);
    on<ResetOrderStatusEvent>(resetOrderStatus);
    on<GetSMSPricingPlansEvent>(getSMSPricingPlans);
    on<PurchaseSMSPackageEvent>(purchaseSMSPackage);
  }

  Future<void> purchaseSMSPackage(PurchaseSMSPackageEvent event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(purchaseStatus: Status.loading));
    try {
      final data = await _repo.purchaseSMSPackage(
        smsPackageId: event.smsPackageId,
        paymentMethod: event.paymentMethod,
        returnUrl: event.returnUrl,
      );

      if (data["status"] == true) {
        final result = PurchaseSubscriptionResult.fromJson(data["result"]);
        emit(state.copyWith(purchaseStatus: Status.success, purchaseResult: result));
      } else {
        emit(state.copyWith(purchaseStatus: Status.error, errorMessage: data["message"]?.toString() ?? 'Unknown error'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(purchaseStatus: Status.error, errorMessage: e.message ?? e.toString()));
    } catch (e) {
      emit(state.copyWith(purchaseStatus: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> getSMSPricingPlans(GetSMSPricingPlansEvent event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(smsStatus: Status.loading));
    try {
      final data = await _repo.getSMSPricingPlans();

      if (data["status"] == true) {
        final plans = (data["result"] as List? ?? [])
            .map((e) => SMSPricingModel.fromJson(e))
            .toList();
        emit(state.copyWith(smsStatus: Status.success, smsPricingPlans: plans));
      } else {
        emit(state.copyWith(smsStatus: Status.error, errorMessage: data["message"]?.toString() ?? 'Unknown error'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(smsStatus: Status.error, errorMessage: e.message ?? e.toString()));
    } catch (e) {
      emit(state.copyWith(smsStatus: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> getPricingPlans(GetPricingPlansEvent event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(status: Status.loading, detailStatus: Status.initial, purchaseStatus: Status.initial));
    try {
      final data = await _repo.getPricingPlans();

      if (data["status"] == true) {
        List<PricingPlanModel> plans = [];
        plans = data["result"].map<PricingPlanModel>((element) => PricingPlanModel.fromJson(element)).toList();
        emit(state.copyWith(status: Status.success, pricingPlans: plans));
      } else {
        emit(state.copyWith(status: Status.error, errorMessage: data["message"]?.toString() ?? 'Unknown error'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.message ?? e.toString()));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> getPricingPlanDetail(GetPricingPlanDetailEvent event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(detailStatus: Status.loading));
    try {
      final data = await _repo.getPricingPlanDetail(id: event.id);

      if (data["status"] == true) {
        final detail = PricingPlanModel.fromJson(data["result"]);
        emit(state.copyWith(detailStatus: Status.success, pricingPlanDetail: detail));
      } else {
        emit(state.copyWith(detailStatus: Status.error, errorMessage: data["message"]?.toString() ?? 'Unknown error'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(detailStatus: Status.error, errorMessage: e.message ?? e.toString()));
    } catch (e) {
      emit(state.copyWith(detailStatus: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> getSubscriptionInfo(GetSubscriptionInfoEvent event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(infoStatus: Status.loading));
    try {
      final data = await _repo.getSubscriptionInfo();

      if (data["status"] == true) {
        final info = SubscriptionInfoModel.fromJson(data["result"]);
        emit(state.copyWith(infoStatus: Status.success, subscriptionInfo: info));
      } else {
        emit(state.copyWith(infoStatus: Status.error, errorMessage: data["message"]?.toString() ?? 'Unknown error'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(infoStatus: Status.error, errorMessage: e.message ?? e.toString()));
    } catch (e) {
      emit(state.copyWith(infoStatus: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> purchaseSubscription(PurchaseSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(purchaseStatus: Status.loading));
    try {
      final request = PurchaseSubscriptionRequest(
        planId: event.planId,
        billingCycle: event.billingCycle,
        paymentMethod: event.paymentMethod,
        returnUrl: event.returnUrl,
      );

      final data = await _repo.purchaseSubscription(request: request);

      if (data["status"] == true) {
        final result = PurchaseSubscriptionResult.fromJson(data["result"]);
        emit(state.copyWith(purchaseStatus: Status.success, purchaseResult: result));
      } else {
        emit(state.copyWith(purchaseStatus: Status.error, errorMessage: data["message"]?.toString() ?? 'Unknown error'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(purchaseStatus: Status.error, errorMessage: e.message ?? e.toString()));
    } catch (e) {
      emit(state.copyWith(purchaseStatus: Status.error, errorMessage: e.toString()));
    }
  }

  void resetPurchaseStatus(ResetPurchaseStatusEvent event, Emitter<SubscriptionState> emit) {
    emit(state.copyWith(purchaseStatus: Status.initial, purchaseResult: null, orderStatus: Status.pure));
  }

  Future<void> checkOrderStatus(CheckOrderStatusEvent event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(orderStatus: Status.loading));
    try {
      final data = await _repo.checkOrderStatus(orderNumber: event.orderNumber);

      if (data["status"] == true) {
        final status = data["result"]["status"]?.toString().toUpperCase();
        if (status == 'PAID') {
          emit(state.copyWith(orderStatus: Status.success));
        } else if (status == 'FAILED') {
          emit(state.copyWith(orderStatus: Status.error, errorMessage: 'To\'lov muvaffaqiyatsiz tugadi'));
        } else {
          // PENDING - emit initial to trigger listener while in loading state
          emit(state.copyWith(orderStatus: Status.initial));
        }
      } else {
        emit(state.copyWith(orderStatus: Status.error, errorMessage: data["message"]?.toString() ?? 'Unknown error'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(orderStatus: Status.error, errorMessage: e.message ?? e.toString()));
    } catch (e) {
      emit(state.copyWith(orderStatus: Status.error, errorMessage: e.toString()));
    }
  }

  void resetOrderStatus(ResetOrderStatusEvent event, Emitter<SubscriptionState> emit) {
    emit(state.copyWith(orderStatus: Status.pure));
  }
}
