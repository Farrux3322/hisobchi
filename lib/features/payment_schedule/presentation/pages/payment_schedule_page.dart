import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../presentation/assets/asset_index.dart';
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
      create: (_) => PaymentScheduleBloc()
        ..add(PaymentScheduleStarted(initialPartner: initialPartner)),
      child: BlocConsumer<PaymentScheduleBloc, PaymentScheduleState>(
        listener: (context, state) {
          if (state.status == PaymentScheduleStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Grafik saqlandi"),
                backgroundColor: AppTheme.colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
            // true = yangi reja yaratildi, ListPage refresh qilsin
            Navigator.pop(context, true);
          } else if (state.status == PaymentScheduleStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Xatolik yuz berdi'),
                backgroundColor: AppTheme.colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: state.currentStep == 0,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop && state.currentStep > 0) {
                context.read<PaymentScheduleBloc>().add(const PaymentStepBack());
              }
            },
            child: Scaffold(
              backgroundColor: AppTheme.colors.background,
              appBar: AppBar(
                backgroundColor: AppTheme.colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.colors.black, size: 22),
                  onPressed: () {
                    if (state.currentStep == 0) {
                      Navigator.pop(context);
                    } else {
                      context.read<PaymentScheduleBloc>().add(const PaymentStepBack());
                    }
                  },
                ),
                title: Text(
                  "Bo'lib to'lash",
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                ),
                centerTitle: true,
              ),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _buildStep(state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(PaymentScheduleState state) {
    switch (state.currentStep) {
      case 0:
        return const Step1BasicInfoPage(key: ValueKey(0));
      case 1:
        return const Step2ScheduleTypePage(key: ValueKey(1));
      case 2:
        if (state.scheduleType == PaymentScheduleType.equal) {
          return const Step3EqualSchedulePage(key: ValueKey(2));
        }
        if (state.scheduleType == PaymentScheduleType.custom) {
          return const Step3FreeSchedulePage(key: ValueKey(3));
        }
        return const Step1BasicInfoPage(key: ValueKey(0));
      default:
        return const Step1BasicInfoPage(key: ValueKey(0));
    }
  }
}
