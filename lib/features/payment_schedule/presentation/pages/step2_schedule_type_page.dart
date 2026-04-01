import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../presentation/assets/theme/app_theme.dart';
import '../../data/models/enums.dart';
import '../bloc/payment_schedule_bloc.dart';
import '../bloc/payment_schedule_event.dart';
import '../bloc/payment_schedule_state.dart';
import '../widgets/common/ps_bottom_buttons.dart';
import '../widgets/common/ps_step_indicator.dart';

class Step2ScheduleTypePage extends StatelessWidget {
  const Step2ScheduleTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentScheduleBloc, PaymentScheduleState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.colors.background,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PSStepIndicator(currentStep: 1),
                      SizedBox(height: 6.h),
                      Text(
                        '2-bosqich · Grafik turi',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Equal schedule card
                      _ScheduleTypeCard(
                        type: PaymentScheduleType.equal,
                        isSelected: state.scheduleType == PaymentScheduleType.equal,
                        title: 'Teng bo\'lib to\'lash',
                        description:
                            'Boshlanish sanasi va qismlar sonini belgilang. Tizim har bir qism uchun teng summani avtomatik hisoblaydi.',
                        icon: Icons.calculate_rounded,
                        color: const Color(0xFFF97316),
                        onTap: () {
                          context.read<PaymentScheduleBloc>().add(
                                const PaymentScheduleTypeSelected(PaymentScheduleType.equal),
                              );
                        },
                      ),
                      SizedBox(height: 12.h),

                      // Free schedule card
                      _ScheduleTypeCard(
                        type: PaymentScheduleType.free,
                        isSelected: state.scheduleType == PaymentScheduleType.free,
                        title: 'Erkin grafik',
                        description:
                            'Har bir qism uchun summa va sanani alohida belgilang. To\'liq moslashuvchanlik va nazorat.',
                        icon: Icons.edit_calendar_rounded,
                        color: AppTheme.colors.primary,
                        onTap: () {
                          context.read<PaymentScheduleBloc>().add(
                                const PaymentScheduleTypeSelected(PaymentScheduleType.free),
                              );
                        },
                      ),

                      if (state.validationErrors.containsKey('type'))
                        Padding(
                          padding: EdgeInsets.only(top: 16.h),
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppTheme.colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: AppTheme.colors.red, size: 20.r),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    state.validationErrors['type']!,
                                    style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.red, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              PSBottomButtons(
                showBack: true,
                onBack: () {
                  context.read<PaymentScheduleBloc>().add(const PaymentStepBack());
                },
                onContinue: () {
                  context.read<PaymentScheduleBloc>().add(const PaymentStepChanged(2));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleTypeCard extends StatelessWidget {
  final PaymentScheduleType type;
  final bool isSelected;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScheduleTypeCard({
    required this.type,
    required this.isSelected,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? color : AppTheme.colors.divider,
            width: isSelected ? 2.5.w : 1.w,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 8))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: color, size: 28.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? color : AppTheme.colors.black,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.colors.gray,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppTheme.colors.divider,
                  width: 2.w,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}
