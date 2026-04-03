import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/enums.dart';
import '../../data/models/payment_partner_model.dart';
import '../bloc/payment_schedule_bloc.dart';
import '../bloc/payment_schedule_event.dart';
import '../bloc/payment_schedule_state.dart';
import 'step1_basic_info_page.dart';
import 'step2_schedule_type_page.dart';
import 'step3_equal_schedule_page.dart';
import 'step3_free_schedule_page.dart';

class PaymentSchedulePage extends StatelessWidget {
  final PaymentPartnerModel? initialPartner;

  const PaymentSchedulePage({super.key, this.initialPartner});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentScheduleBloc()
        ..add(PaymentScheduleStarted(initialPartner: initialPartner)),
      child: BlocConsumer<PaymentScheduleBloc, PaymentScheduleState>(
        listener: (context, state) {
          if (state.status == PaymentScheduleStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Grafik saqlandi va SMS yuborildi'),
                backgroundColor: Color(0xFF00D856),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pop(context);
          } else if (state.status == PaymentScheduleStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Xatolik yuz berdi'),
                backgroundColor: const Color(0xFFDE5050),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: state.currentStep == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && state.currentStep > 0) {
                context.read<PaymentScheduleBloc>().add(
                      const PaymentStepBack(),
                    );
              }
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF202020),
                  ),
                  onPressed: () {
                    if (state.currentStep == 0) {
                      Navigator.pop(context);
                    } else {
                      context.read<PaymentScheduleBloc>().add(
                            const PaymentStepBack(),
                          );
                    }
                  },
                ),
                title: const Text(
                  'Bo\'lib to\'lash',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202020),
                  ),
                ),
                centerTitle: true,
              ),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                  );

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                child: _buildCurrentStep(state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep(PaymentScheduleState state) {
    // Step 0: Basic info
    if (state.currentStep == 0) {
      return const Step1BasicInfoPage(key: ValueKey(0));
    }

    // Step 1: Schedule type
    if (state.currentStep == 1) {
      return const Step2ScheduleTypePage(key: ValueKey(1));
    }

    // Step 2: Details based on schedule type
    if (state.currentStep == 2) {
      if (state.scheduleType == PaymentScheduleType.equal) {
        return const Step3EqualSchedulePage(key: ValueKey(2));
      } else if (state.scheduleType == PaymentScheduleType.free) {
        return const Step3FreeSchedulePage(key: ValueKey(3));
      }
    }

    // Fallback to step 0
    return const Step1BasicInfoPage(key: ValueKey(0));
  }
}
