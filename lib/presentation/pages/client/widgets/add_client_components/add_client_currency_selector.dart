import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/currency/currency_model.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

class AddClientCurrencySelector extends StatelessWidget {
  final Result? selectedCurrency;
  final VoidCallback onTap;

  const AddClientCurrencySelector({
    super.key,
    this.selectedCurrency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, currencyState) {
        final currencies = currencyState.currencyModel?.result ?? [];
        final isLoadingCurrencies = currencyState.status == Status.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                text: 'Valyuta ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                children: [
                  TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Currency selector card
            GestureDetector(
              onTap: isLoadingCurrencies || (currencies.isEmpty && !isLoadingCurrencies) ? null : onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    if (selectedCurrency != null) const SizedBox(width: 12),

                    // Currency name or placeholder
                    Expanded(
                      child: selectedCurrency != null
                          ? Text(
                              selectedCurrency!.name ?? '',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                            )
                          : Text(
                              isLoadingCurrencies ? 'Yuklanmoqda...' : 'Asosiy valyutani tanlang',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            ),
                    ),

                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: selectedCurrency != null ? AppTheme.colors.primary : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
