import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../presentation/assets/theme/app_theme.dart';
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
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(4.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCurrencyButton(
            label: 'UZS',
            currency: PaymentCurrency.uzs,
          ),
          SizedBox(width: 4.w),
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
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.colors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppTheme.colors.white : AppTheme.colors.gray,
          ),
        ),
      ),
    );
  }
}
