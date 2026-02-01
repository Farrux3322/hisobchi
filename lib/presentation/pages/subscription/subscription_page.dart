import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/pages/subscription/subscription_detail_page.dart';
import 'package:hisobchi/presentation/pages/subscription/widgets/tarif_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackArrowButton(),
        title: const Text(
          'Obuna sotib olish',
        ),
        centerTitle: true,
      ),
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
                        if (selectedPlan.id != null) {
                          context.pushNamed(
                            Routes.subscriptionDetail.name,
                            extra: {
                              'planId': selectedPlan.id,
                              'planName': selectedPlan.displayName ?? selectedPlan.name ?? '',
                            },
                          );
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
              Gap(MediaQuery.of(context).padding.bottom+10)
            ],
          );
        },
      ),
    );
  }
}
