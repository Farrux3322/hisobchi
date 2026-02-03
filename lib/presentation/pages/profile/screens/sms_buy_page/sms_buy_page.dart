import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hisobchi/infrastructure/dto/models/subscription/sms_pricing_model.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class SMSBuyPage extends StatefulWidget {
  const SMSBuyPage({super.key});

  @override
  State<SMSBuyPage> createState() => _SMSBuyPageState();
}

class _SMSBuyPageState extends State<SMSBuyPage> with WidgetsBindingObserver {
  int _selectedPackageIndex = 0;
  bool isWaitingForPayment = false;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<SubscriptionBloc>().add(GetSMSPricingPlansEvent());
    context.read<SubscriptionBloc>().add(GetSubscriptionInfoEvent());
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');
    if (uri.scheme == 'hisobchi' && uri.host == 'payment-success') {
      if (mounted && isWaitingForPayment) {
        _verifyPayment();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _verifyPayment() {
    final orderNumber = context.read<SubscriptionBloc>().state.purchaseResult?.orderNumber;
    if (orderNumber != null) {
      context.read<SubscriptionBloc>().add(CheckOrderStatusEvent(orderNumber));
    } else {
      context.read<SubscriptionBloc>().add(GetSubscriptionInfoEvent());
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('To\'lov sahifasini ochib bo\'lmadi')),
        );
      }
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return "0";
    String priceStr = price.toString();
    if (priceStr.contains('.')) {
      priceStr = priceStr.split('.').first;
    }
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return priceStr.replaceAllMapped(reg, (Match match) => '${match[1]} ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state.purchaseStatus == Status.success && state.purchaseResult != null) {
          if (state.purchaseResult!.paymentUrl != null && !isWaitingForPayment) {
            _launchPaymentUrl(state.purchaseResult!.paymentUrl!);
            setState(() {
              isWaitingForPayment = true;
            });
          }
        } else if (state.purchaseStatus == Status.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage.isNotEmpty ? state.errorMessage : 'Xarid amalga oshmadi'),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state.orderStatus == Status.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state.orderStatus == Status.success) {
          _showSuccessDialog();
        } else if (state.orderStatus == Status.initial && isWaitingForPayment) {
          _showPendingDialog();
          context.read<SubscriptionBloc>().add(ResetOrderStatusEvent());
        }
      },
      child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          final isLoading = state.smsStatus == Status.loading;
          final packages = state.smsPricingPlans;
          
          if (_selectedPackageIndex >= packages.length && packages.isNotEmpty) {
            _selectedPackageIndex = 0;
          }

          final selectedPackage = packages.isNotEmpty ? packages[_selectedPackageIndex] : null;

          if (isWaitingForPayment) {
            return Scaffold(
              backgroundColor: AppTheme.colors.background,
              appBar: _buildAppBar(context),
              body: _buildWaitingForPaymentUI(state),
            );
          }

          return Scaffold(
            backgroundColor: AppTheme.colors.background,
            appBar: _buildAppBar(context),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        _buildHeader(),
                        SizedBox(height: 12.h),
                        isLoading ? _buildShimmerSelection() : _buildPackageSelection(packages),
                        SizedBox(height: 12.h),
                        if (!isLoading && selectedPackage != null)
                          _buildSelectedPlanDetails(selectedPackage)
                        else if (isLoading)
                          _buildShimmerDetails(),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
                if (!isLoading && selectedPackage != null)
                  _buildCheckoutFooter(selectedPackage)
                else if (isLoading)
                  _buildShimmerFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "SMS To'plami",
        style: TextStyle(
          color: AppTheme.colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      leading: const BackArrowButton(),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        final remaining = state.subscriptionInfo?.subscription?.usage?.sms?.remaining ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Yangi to'plam tanlang",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  "Sizda hozirda ",
                  style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                ),
                Text(
                  "$remaining ta SMS",
                  style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.primary, fontWeight: FontWeight.w700),
                ),
                Text(
                  " mavjud",
                  style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPackageSelection(List<SMSPricingModel> packages) {
    return Column(
      children: List.generate(packages.length, (index) {
        final package = packages[index];
        final isSelected = _selectedPackageIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedPackageIndex = index);
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isSelected ? AppTheme.colors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppTheme.colors.primary.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${package.smsCount} SMS",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppTheme.colors.primary : AppTheme.colors.black,
                            ),
                          ),
                          Text(
                            "${_formatPrice(package.price)} so'm",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        package.description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.colors.black.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.colors.primary : AppTheme.colors.divider,
                      width: isSelected ? 8.w : 2.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSelectedPlanDetails(SMSPricingModel package) {
    final double price = double.tryParse(package.price) ?? 0;
    final unitPrice = _formatPrice((price / package.smsCount).toStringAsFixed(0));

    return Container(
      width: 1.sw,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.colors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tanlangan to'plam tafsilotlari",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
          ),
          SizedBox(height: 16.h),
          _buildMetricRow(Icons.onetwothree_rounded, "SMS soni", "${package.smsCount} ta"),
          SizedBox(height: 12.h),
          _buildMetricRow(Icons.payments_outlined, "Bitta SMS narxi", "$unitPrice so'm"),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: AppTheme.colors.divider.withValues(alpha: 0.5), height: 1),
          ),
          _buildMetricRow(Icons.wallet_rounded, "Umumiy qiymat", "${_formatPrice(package.price)} so'm"),
        ],
      ),
    );
  }

  Widget _buildMetricRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppTheme.colors.black.withValues(alpha: 0.4)),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black.withValues(alpha: 0.6)),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
        ),
      ],
    );
  }

  Widget _buildCheckoutFooter(SMSPricingModel package) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showPaymentMethodBottomSheet(package);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(double.infinity, 56.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: Text(
          "Sotib olish",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  void _handlePurchase(SMSPricingModel package, String method) {
    context.read<SubscriptionBloc>().add(
          PurchaseSMSPackageEvent(
            smsPackageId: package.id,
            paymentMethod: method,
            returnUrl: 'hisobchi://payment-success',
          ),
        );
  }

  void _showPaymentMethodBottomSheet(SMSPricingModel package) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.colors.divider.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "To'lov usulini tanlang",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
            ),
            SizedBox(height: 8.h),
            Text(
              "SMS paketini xarid qilish uchun to'lov tizimini tanlang",
              style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 24.h),
            _buildPaymentMethodItem(
              icon: AppIcons.payme,
              label: "Payme",
              onTap: () {
                Navigator.pop(context);
                _handlePurchase(package, 'payme');
              },
            ),
            SizedBox(height: 12.h),
            _buildPaymentMethodItem(
              icon: AppIcons.click,
              label: "Click",
              onTap: () {
                Navigator.pop(context);
                _handlePurchase(package, 'click');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem({required String icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.colors.background.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.colors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(icon, width: 32.w, height: 32.w),
            // SizedBox(width: 16.w),
            // Text(
            //   label,
            //   style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
            // ),
            // const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: AppTheme.colors.black.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    context.pushReplacementNamed(Routes.paymentSuccess.name);
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.hourglass_empty_rounded, color: const Color(0xFFF59E0B), size: 40.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                "To'lov kutilmoqda",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
              ),
              SizedBox(height: 12.h),
              Text(
                "To'lov hali yakunlanmadi. Iltimos, bir ozdan so'ng qayta urinib ko'ring.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black.withValues(alpha: 0.5), height: 1.5),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.black,
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: const Text("Tushundim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingForPaymentUI(SubscriptionState state) {
    final isVerifying = state.infoStatus == Status.loading || state.orderStatus == Status.loading;

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.schedule_rounded, size: 64.sp, color: AppTheme.colors.primary),
          ),
          SizedBox(height: 24.h),
          Text(
            "To'lov kutilmoqda",
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppTheme.colors.black),
          ),
          SizedBox(height: 12.h),
          Text(
            "To'lovni amalga oshirganingizdan so'ng pastdagi tugmani bosing",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: AppTheme.colors.black.withValues(alpha: 0.5), height: 1.5),
          ),
          const Spacer(),
          if (state.purchaseResult?.orderNumber != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppTheme.colors.divider),
              ),
              child: Text(
                "Buyurtma raqami: ${state.purchaseResult!.orderNumber}",
                style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.colors.black),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          ElevatedButton(
            onPressed: isVerifying ? null : _verifyPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            child: isVerifying
                ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Text("To'lovni tekshirish", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () {
              if (state.purchaseResult?.paymentUrl != null) {
                _launchPaymentUrl(state.purchaseResult!.paymentUrl!);
              }
            },
            child: Text("To'lov sahifasiga qaytish", style: TextStyle(color: AppTheme.colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildShimmerSelection() {
    return Column(
      children: List.generate(3, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.black.withValues(alpha: 0.05),
          highlightColor: Colors.black.withValues(alpha: 0.01),
          child: Container(
            height: 100.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShimmerDetails() {
    return Shimmer.fromColors(
      baseColor: Colors.black.withValues(alpha: 0.05),
      highlightColor: Colors.black.withValues(alpha: 0.01),
      child: Container(
        height: 160.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
    );
  }

  Widget _buildShimmerFooter() {
    return Shimmer.fromColors(
      baseColor: Colors.black.withValues(alpha: 0.05),
      highlightColor: Colors.black.withValues(alpha: 0.01),
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
      ),
    );
  }
}
