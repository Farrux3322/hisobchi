import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/subscription/subscription_info_model.dart';
import 'package:hisobchi/presentation/assets/res/app_icons.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/pages/subscription/payment_success_page.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:io' show Platform;

enum TariffType { monthly, semiAnnual, annual }

enum PaymentType { card, click }

class AppColors {
  static const primary = Color(0xFF6366F1);
  static const green = Color(0xFF34C759);
  static const background = Color(0xFFF5F5F7);
  static const borderGray = Color(0xFFE5E5EA);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF8E8E93);
}

class SubscriptionDetailPage extends StatefulWidget {
  final int planId;
  final String planName;

  const SubscriptionDetailPage({super.key, required this.planId, required this.planName});

  @override
  State<SubscriptionDetailPage> createState() => _SubscriptionDetailPageState();
}

class _SubscriptionDetailPageState extends State<SubscriptionDetailPage> with WidgetsBindingObserver {
  TariffType selectedTariff = TariffType.annual;
  PaymentType selectedPayment = PaymentType.card;
  bool isWaitingForPayment = false;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  SubscriptionDetail? _initialSubscription;
  bool _deepLinkReceived = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<SubscriptionBloc>().add(GetPricingPlanDetailEvent(widget.planId));
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Check for initial link when app is opened via deep link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });

    // Listen to incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');
    if (uri.scheme == 'hisobchi' && uri.host == 'payment-success') {
      if (mounted && isWaitingForPayment) {
        setState(() {
          _deepLinkReceived = true;
        });
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // We remove automatic verification here to avoid false positives 
    // when returning to the app manually without paying. 
    // The user can still press the "Verify" button manually.
  }

  String _formatPrice(String? amount) {
    if (amount == null) return '0';
    final numValue = double.tryParse(amount) ?? 0;
    return numValue.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  String _getBillingCycle() {
    switch (selectedTariff) {
      case TariffType.monthly:
        return 'MONTHLY';
      case TariffType.semiAnnual:
        return 'SEMI_ANNUAL';
      case TariffType.annual:
        return 'ANNUAL';
    }
  }

  String _getPaymentMethod() {
    switch (selectedPayment) {
      case PaymentType.card:
        return 'payme';
      case PaymentType.click:
        return 'click';
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

  void _handlePurchase() {
    context.read<SubscriptionBloc>().add(
          PurchaseSubscriptionEvent(
            planId: widget.planId,
            billingCycle: _getBillingCycle(),
            paymentMethod: _getPaymentMethod(),
            returnUrl: 'hisobchi://payment-success',
          ),
        );
  }

  void _verifyPayment() {
    final orderNumber = context.read<SubscriptionBloc>().state.purchaseResult?.orderNumber;
    if (orderNumber != null) {
      context.read<SubscriptionBloc>().add(CheckOrderStatusEvent(orderNumber));
    } else {
      context.read<SubscriptionBloc>().add(GetSubscriptionInfoEvent());
    }
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty_rounded,
                  color: Color(0xFFF59E0B),
                  size: 40,
                ),
              ),
              const Gap(24),
              const Text(
                'To\'lov kutilmoqda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1F),
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(12),
              const Text(
                'To\'lov hali yakunlanmadi. Iltimos, bir ozdan so\'ng qayta urinib ko\'ring.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF8E8E93),
                  height: 1.5,
                ),
              ),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D1D1F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tushundim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          // Reset orderStatus to pure so it can be triggered again on next click
          context.read<SubscriptionBloc>().add(ResetOrderStatusEvent());
        }

        if (state.infoStatus == Status.success) {
          if (_initialSubscription == null && state.subscriptionInfo?.subscription != null) {
            _initialSubscription = state.subscriptionInfo!.subscription;
          }

          if (isWaitingForPayment) {
            final currentSub = state.subscriptionInfo?.subscription;
            final subStatus = currentSub?.status?.toLowerCase();
            
            bool isSuccess = false;

            // 1. If we got a deep link, it's a guaranteed success signal from the gateway
            if (_deepLinkReceived && subStatus == 'active') {
              isSuccess = true;
            } 
            // 2. If no deep link, check if the subscription state actually changed
            else if (currentSub != null && _initialSubscription != null) {
              // Plan changed
              if (currentSub.plan?.id != _initialSubscription?.plan?.id) {
                isSuccess = subStatus == 'active';
              } 
              // Payment date changed (meaning a new payment was processed)
              else if (currentSub.lastPayment?.date != _initialSubscription?.lastPayment?.date) {
                isSuccess = subStatus == 'active';
              }
              // Subscription was inactive and became active
              else if (_initialSubscription?.status?.toLowerCase() != 'active' && subStatus == 'active') {
                isSuccess = true;
              }
            }

            if (isSuccess) {
              _showSuccessDialog();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: const BackArrowButton(),
          title: Text(
            widget.planName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state.detailStatus == Status.loading && !isWaitingForPayment) {
              return const Loading();
            }

            if (state.detailStatus == Status.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Xatolik yuz berdi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SubscriptionBloc>().add(GetPricingPlanDetailEvent(widget.planId));
                      },
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              );
            }

            if (state.pricingPlanDetail == null) {
              return const Center(child: Text('Ma\'lumot topilmadi'));
            }

            final plan = state.pricingPlanDetail!;

            if (isWaitingForPayment) {
              return _buildWaitingForPaymentUI(state);
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tarif muddatini tanlang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (plan.monthlyPrice != null)
                          _buildTariffCard(
                            type: TariffType.monthly,
                            label: 'Oylik',
                            price: plan.monthlyPrice!.amount,
                            discount: null,
                            description: null,
                          ),
                        if (plan.semiAnnualPrice != null)
                          _buildTariffCard(
                            type: TariffType.semiAnnual,
                            label: '6 oylik',
                            price: plan.semiAnnualPrice!.amount,
                            discount: plan.semiAnnualPrice!.discountValue > 0 ? plan.semiAnnualPrice!.discountValue : null,
                            description: plan.semiAnnualPrice!.description,
                          ),
                        if (plan.annualPrice != null)
                          _buildTariffCard(
                            type: TariffType.annual,
                            label: 'Yillik',
                            price: plan.annualPrice!.amount,
                            discount: plan.annualPrice!.discountValue > 0 ? plan.annualPrice!.discountValue : null,
                            description: plan.annualPrice!.description != null && plan.annualPrice!.description!.isNotEmpty
                                ? '${plan.annualPrice!.description!} ${plan.annualPrice!.description1 ?? ''}'
                                : null,
                          ),
                        const Text(
                          'To\'lov turini tanlang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentMethodSection(plan),
                        const Gap(24),
                        _buildPurchaseButton(state),
                        Gap(MediaQuery.of(context).padding.bottom + 10)
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(dynamic plan) {
    final List<Widget> methods = [];
    if (plan.paymentMethods != null && plan.paymentMethods!.contains('PAYME')) {
      methods.add(
        _buildPaymentCard(
          type: PaymentType.card,
          label: 'Payme',
          icon: AppIcons.payme,
        ),
      );
      methods.add(const Gap(12));
    }
    if (plan.paymentMethods != null && plan.paymentMethods!.contains('CLICK')) {
      methods.add(
        _buildPaymentCard(
          type: PaymentType.click,
          label: 'Click',
          icon: AppIcons.click,
        ),
      );
    }
    return Column(children: methods);
  }

  Widget _buildPurchaseButton(SubscriptionState state) {
    final isLoading = state.purchaseStatus == Status.loading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handlePurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Xarid qilish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildWaitingForPaymentUI(SubscriptionState state) {
    final isVerifying = state.infoStatus == Status.loading;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const Gap(24),
          const Text(
            'To\'lov kutilmoqda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(12),
          const Text(
            'To\'lovni amalga oshirganingizdan so\'ng pastdagi tugmani bosing',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const Spacer(),
          if (state.purchaseResult?.orderNumber != null) ...[
            const Gap(16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: Text(
                'Buyurtma raqami: ${state.purchaseResult!.orderNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          const Gap(40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isVerifying ? null : _verifyPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: isVerifying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'To\'lovni tekshirish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const Gap(16),
          TextButton(
            onPressed: () {
              if (state.purchaseResult?.paymentUrl != null) {
                _launchPaymentUrl(state.purchaseResult!.paymentUrl!);
              }
            },
            child: const Text('To\'lov sahifasiga qaytish'),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTariffCard({
    required TariffType type,
    required String label,
    required String? price,
    required double? discount,
    required String? description,
  }) {
    final isSelected = selectedTariff == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTariff = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${_formatPrice(price)} uzs',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (discount != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(-${discount.toInt()}%)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.green : AppColors.borderGray,
                  width: 2,
                ),
                color: isSelected ? AppColors.green : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required PaymentType type,
    required String label,
    required String icon,
  }) {
    final isSelected = selectedPayment == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.colors.primary : AppColors.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(icon, width: 32, height: 32),
            // const SizedBox(width: 12),
            // Expanded(
            //   child: Text(
            //     label,
            //     style: const TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.w500,
            //       color: AppColors.textPrimary,
            //     ),
            //   ),
            // ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.colors.primary : AppColors.borderGray,
                  width: 2,
                ),
                color: isSelected ? AppTheme.colors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}