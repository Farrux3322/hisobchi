import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/pages/subscription/widgets/tarif_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';

import '../../../infrastructure/dto/models/subscription/pricing_plan_model.dart';

class TariflarScreen extends StatefulWidget {
  const TariflarScreen({super.key});

  @override
  State<TariflarScreen> createState() => _TariflarScreenState();
}

class _TariflarScreenState extends State<TariflarScreen> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(GetPricingPlansEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: BackArrowButton(), title: const Text('Obuna sotib olish'), centerTitle: true),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state.status == Status.loading) {
            return Loading();
          }

          if (state.status == Status.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Xatolik yuz berdi', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(GetPricingPlansEvent());
                    },
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            );
          }

          if (state.pricingPlans.isEmpty) {
            return const Center(child: Text('Hozircha tariflar mavjud emas'));
          }

          return Column(
            children: [
              Expanded(
                child: CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: state.pricingPlans.length,
                  itemBuilder: (context, index, realIndex) {
                    return TarifCard(tarif: state.pricingPlans[index]);
                  },
                  options: CarouselOptions(
                    enlargeFactor: 0.2,
                    height: double.infinity,
                    viewportFraction: 0.88,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.scale,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (state.pricingPlans.isNotEmpty && _currentIndex < state.pricingPlans.length) {
                        final selectedPlan = state.pricingPlans[_currentIndex];

                        // Check if subscription is allowed
                        if (!(selectedPlan.canSubscribe ?? true)) {
                          _showDowngradeDialog(context, selectedPlan);
                          return;
                        }

                        if (selectedPlan.id != null) {
                          context.pushNamed(Routes.subscriptionDetail.name, extra: {'planId': selectedPlan.id, 'planName': selectedPlan.displayName ?? selectedPlan.name ?? ''});
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Xarid qilish',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Gap(MediaQuery.of(context).padding.bottom + 10),
            ],
          );
        },
      ),
    );
  }

  void _showDowngradeDialog(BuildContext context, PricingPlanModel plan) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 20))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium Header with Animated-style Gradient
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF59E0B), // Amber 400
                              const Color(0xFFE11D48), // Rose 600
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 48),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Limitlar oshib ketgan',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: plan.displayName ?? plan.name ?? '',
                                style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: " tarifiga o'tish uchun hozirgi ",
                                    style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: "hamkorlar va loyihalar",
                                    style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: "ingiz soni ushbu tarif limitidan oshmasligi kerak!",
                                    style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (plan.downgradeWarnings != null && plan.downgradeWarnings!.isNotEmpty)
                              ...plan.downgradeWarnings!.map((warning) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade200, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                        child: SvgPicture.asset(_getWarningIcon(warning.field), colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getWarningTitle(warning.field),
                                              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 0.5),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              warning.message ?? 'Limit oshib ketgan',
                                              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                            else
                              const Text(
                                'Tushunarsiz xatolik yuz berdi. Iltimos qayta urinib ko\'ring.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),

                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.colors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Tushunarli',
                                  style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getWarningIcon(String? field) {
    if (field == null) return AppIcons.info;
    switch (field.toLowerCase()) {
      case 'customers':
        return AppIcons.clients;
      case 'projects':
        return AppIcons.project;
      case 'users':
        return AppIcons.clients;
      default:
        return AppIcons.info;
    }
  }

  String _getWarningTitle(String? field) {
    if (field == null) return 'CHEKLOV';
    switch (field.toLowerCase()) {
      case 'customers':
        return 'HAMKORLAR';
      case 'projects':
        return 'LOYIHALAR';
      case 'users':
        return 'FOYDALANUVCHILAR';
      default:
        return 'CHEKLOV';
    }
  }
}
