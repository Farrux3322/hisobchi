import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/application/subscription/subscription_bloc.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({
    super.key,
    required this.isTarif,
  });

  final bool isTarif;



  String get _title =>
      isTarif ? "Tarif muvaffaqiyatli faollashtirildi!" : "SMS paket muvaffaqiyatli sotib olindi!";

  String get _description => isTarif
      ? "Sizning tarifingiz muvaffaqiyatli yangilandi. Endi barcha premium imkoniyatlardan foydalanishingiz mumkin."
      : "SMS paketingiz muvaffaqiyatli faollashtirildi. Endi yuborish limitidan bemalol foydalanishingiz mumkin.";

  String get _buttonText =>
      isTarif ? "Profilga o'tish" : "Asosiy sahifaga qaytish";



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _SuccessIcon(),
                const Gap(40),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1D1F),
                    letterSpacing: -0.3,
                  ),
                ),
                const Gap(16),
                Text(
                  _description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8E8E93),
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _onContinuePressed(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34C759),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onContinuePressed(BuildContext context) {
    final bloc = context.read<SubscriptionBloc>();

    bloc.add(ResetPurchaseStatusEvent());
    bloc.add(GetSubscriptionInfoEvent());

    context.go(Routes.profilePage.path);
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF34C759).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF34C759),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF34C759),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }
}