import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          backgroundColor: const Color(0xFFF5F6F8),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PSStepIndicator(currentStep: 1),
                      const SizedBox(height: 24),
                      const Text(
                        '2-bosqich · Grafik turi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202020),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Equal schedule card
                      _ScheduleTypeCard(
                        type: PaymentScheduleType.equal,
                        isSelected: state.scheduleType == PaymentScheduleType.equal,
                        title: 'Teng bo\'lib to\'lash',
                        description:
                            'Boshlanish sanasi va qismlar sonini belgilang. Tizim har bir qism uchun teng summani avtomatik hisoblaydi. Avans to\'lovini ixtiyoriy qo\'shishingiz mumkin.',
                        icon: Icons.calculate_outlined,
                        color: const Color(0xFFFF9500),
                        onTap: () {
                          context.read<PaymentScheduleBloc>().add(
                                const PaymentScheduleTypeSelected(
                                  PaymentScheduleType.equal,
                                ),
                              );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Free schedule card
                      _ScheduleTypeCard(
                        type: PaymentScheduleType.free,
                        isSelected: state.scheduleType == PaymentScheduleType.free,
                        title: 'Erkin grafik',
                        description:
                            'Har bir qism uchun summa va sanani alohida belgilang. Birinchi qism avtomatik ravishda avans sifatida belgilanadi. To\'liq moslashuvchanlik.',
                        icon: Icons.edit_calendar_outlined,
                        color: const Color(0xFF006FE5),
                        onTap: () {
                          context.read<PaymentScheduleBloc>().add(
                                const PaymentScheduleTypeSelected(
                                  PaymentScheduleType.free,
                                ),
                              );
                        },
                      ),

                      if (state.validationErrors.containsKey('type'))
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDE5050).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFDE5050).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFDE5050),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.validationErrors['type']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFDE5050),
                                    ),
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
                  context.read<PaymentScheduleBloc>().add(
                        const PaymentStepBack(),
                      );
                },
                onContinue: () {
                  context.read<PaymentScheduleBloc>().add(
                        const PaymentStepChanged(2),
                      );
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE1E0EE),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : const Color(0xFFE1E0EE),
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? color : const Color(0xFF202020),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
