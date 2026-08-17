import 'package:ehisob/infrastructure/common/network_provider.dart';
import 'package:ehisob/infrastructure/dto/models/subscription/purchase_subscription_model.dart';

class SubscriptionRepository {
  Future<Map<String, dynamic>> getPricingPlans() async {
    final response = await dio.get('/pricing-plans');
    return response.data;
  }

  Future<Map<String, dynamic>> getPricingPlanDetail({required int id}) async {
    final response = await dio.get('/pricing-plans/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> getSubscriptionInfo() async {
    final response = await dio.get('/subscription/show');
    return response.data;
  }

  Future<Map<String, dynamic>> purchaseSubscription({
    required PurchaseSubscriptionRequest request,
  }) async {
    final response = await dio.post(
      '/subscription/purchase',
      data: request.toJson(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> checkOrderStatus({required String orderNumber}) async {
    final response = await dio.get('/subscription/check-order-status/$orderNumber');
    return response.data;
  }

  Future<Map<String, dynamic>> getSMSPricingPlans() async {
    final response = await dio.get('/pricing-sms');
    return response.data;
  }

  Future<Map<String, dynamic>> purchaseSMSPackage({
    required int smsPackageId,
    required String paymentMethod,
    required String returnUrl,
  }) async {
    final response = await dio.post(
      '/pricing-sms/purchase',
      data: {
        'sms_package_id': smsPackageId,
        'payment_provider': paymentMethod,
        'return_url': returnUrl,
      },
    );
    return response.data;
  }
}