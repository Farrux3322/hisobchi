import 'package:flutter/material.dart';
import '../../../data/models/enums.dart';

class PSCurrencySelector extends StatelessWidget {
  final PaymentCurrency selectedCurrency;
  final ValueChanged<PaymentCurrency> onChanged;

  const PSCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCurrencyButton(
            label: 'UZS',
            currency: PaymentCurrency.uzs,
          ),
          const SizedBox(width: 4),
          _buildCurrencyButton(
            label: 'USD',
            currency: PaymentCurrency.usd,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyButton({
    required String label,
    required PaymentCurrency currency,
  }) {
    final isSelected = selectedCurrency == currency;

    return GestureDetector(
      onTap: () => onChanged(currency),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006FE5) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
