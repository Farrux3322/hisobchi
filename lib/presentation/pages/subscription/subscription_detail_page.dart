import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/res/app_icons.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';

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

  const SubscriptionDetailPage({super.key, required this.planId});

  @override
  State<SubscriptionDetailPage> createState() => _SubscriptionDetailPageState();
}

class _SubscriptionDetailPageState extends State<SubscriptionDetailPage> {
  TariffType selectedTariff = TariffType.annual;
  PaymentType selectedPayment = PaymentType.card;

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(GetPricingPlanDetailEvent(widget.planId));
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
        return 'SEMI_ANNUAL';//SEMI_ANNUAL
      case TariffType.annual:
        return 'ANNUAL';
    }
  }

  String _getPaymentMethod() {
    switch (selectedPayment) {
      case PaymentType.card:
        return 'PAYME';
      case PaymentType.click:
        return 'CLICK';
    }
  }

  // Future<void> _launchPaymentUrl(String url) async {
  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('To\'lov sahifasini ochib bo\'lmadi')),
  //       );
  //     }
  //   }
  // }

  void _handlePurchase() {
    context.read<SubscriptionBloc>().add(
      PurchaseSubscriptionEvent(
        planId: widget.planId,
        billingCycle: _getBillingCycle(),
        paymentMethod: _getPaymentMethod(),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false, // Prevent back button from closing
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 56,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Muvaffaqiyatli!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                const Text(
                  'Tarif muvaffaqiyatli sotib olindi',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Reset purchase status first to prevent dialog from showing again
                      context.read<SubscriptionBloc>().add(ResetPurchaseStatusEvent());

                      // Close dialog
                      Navigator.of(dialogContext).pop();

                      // Wait a bit for dialog to close
                      await Future.delayed(const Duration(milliseconds: 100));

                      // Close all subscription pages and go back to profile
                      if (mounted) {
                        // Pop until we reach the profile page
                        // This will close both subscription_detail_page and subscription_page
                        Navigator.of(context).popUntil((route) => route.isFirst);

                        // Wait for navigation to complete
                        await Future.delayed(const Duration(milliseconds: 100));

                        // Trigger refresh on profile page
                        if (mounted) {
                          context.read<SubscriptionBloc>().add(GetSubscriptionInfoEvent());
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'OK',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state.purchaseStatus == Status.success && state.purchaseResult != null) {
          // Show success dialog
          _showSuccessDialog();
        } else if (state.purchaseStatus == Status.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage.isNotEmpty ? state.errorMessage : 'Xarid amalga oshmadi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state.detailStatus == Status.success && state.pricingPlanDetail != null) {
              return Text(
                state.pricingPlanDetail!.displayName ?? state.pricingPlanDetail!.name ?? '',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              );
            }
            return const Text(
              '',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state.detailStatus == Status.loading) {
            return Loading();
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
                      if (plan.paymentMethods != null && plan.paymentMethods!.contains('PAYME'))
                        _buildPaymentCard(
                          type: PaymentType.card,
                          label: 'VISA / MasterCard',
                          icon: Icons.credit_card,
                        ),
                      const SizedBox(height: 8),
                      if (plan.paymentMethods != null && plan.paymentMethods!.contains('CLICK'))
                        _buildPaymentCard(
                          type: PaymentType.click,
                          label: 'Click',
                          icon: Icons.payment,
                        ),
Gap(10),
                      BlocBuilder<SubscriptionBloc, SubscriptionState>(
                        builder: (context, purchaseState) {
                          final isLoading = purchaseState.purchaseStatus == Status.loading;

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
                        },
                      ),
                      Gap(MediaQuery.of(context).padding.bottom+10)
                    ],
                  ),
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withValues(alpha: 0.05),
              //         blurRadius: 10,
              //         offset: const Offset(0, -2),
              //       ),
              //     ],
              //   ),
              //   child: SafeArea(
              //     child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
              //       builder: (context, purchaseState) {
              //         final isLoading = purchaseState.purchaseStatus == Status.loading;
              //
              //         return SizedBox(
              //           width: double.infinity,
              //           height: 56,
              //           child: ElevatedButton(
              //             onPressed: isLoading ? null : _handlePurchase,
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: AppTheme.colors.primary,
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(16),
              //               ),
              //               elevation: 0,
              //             ),
              //             child: isLoading
              //                 ? const SizedBox(
              //                     width: 24,
              //                     height: 24,
              //                     child: CircularProgressIndicator(
              //                       strokeWidth: 2,
              //                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              //                     ),
              //                   )
              //                 : const Text(
              //                     'Xarid qilish',
              //                     style: TextStyle(
              //                       fontSize: 16,
              //                       fontWeight: FontWeight.w600,
              //                       color: Colors.white,
              //                     ),
              //                   ),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
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
    required IconData icon,
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
            color: isSelected ? AppColors.primary : AppColors.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(AppIcons.click),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderGray,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
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