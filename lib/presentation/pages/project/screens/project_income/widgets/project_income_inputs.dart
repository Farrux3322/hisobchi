import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ehisob/presentation/assets/theme/app_theme.dart';

class ProjectIncomeInputs extends StatelessWidget {
  final TextEditingController summaController;
  final TextEditingController descriptionController;
  final FocusNode summaFocusNode;
  final FocusNode descriptionFocusNode;
  final Widget? currencySelector;

  const ProjectIncomeInputs({
    super.key,
    required this.summaController,
    required this.descriptionController,
    required this.summaFocusNode,
    required this.descriptionFocusNode,
    this.currencySelector,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildPriceTextField(
                controller: summaController,
                focusNode: summaFocusNode,
                label: 'Miqdor',
                hint: 'Summani kiriting',
                icon: Icons.payments_outlined,
                isRequired: true,
              ),
            ),
            if (currencySelector != null) ...[
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: currencySelector!,
              ),
            ],
          ],
        ),
        SizedBox(height: 20.h),
        _buildTextField(
          controller: descriptionController,
          focusNode: descriptionFocusNode,
          label: 'Izoh',
          hint: 'Qo\'shimcha ma\'lumot (ixtiyoriy)',
          icon: Icons.description_outlined,
          maxLines: null,
        ),
      ],
    );
  }

  Widget _buildPriceTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          maxLength: 14,
          inputFormatters: [
            _NumberInputFormatter(),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Summani kiriting';
            }
            final number = double.tryParse(value.replaceAll(',', '').replaceAll(' ', ''));
            if (number == null || number <= 0) {
              return 'To\'g\'ri summa kiriting';
            }
            return null;
          },
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLength: 100,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      counter: SizedBox(),
      hintStyle: TextStyle(
        color: const Color(0xFF94A3B8),
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Container(
        margin: EdgeInsets.only(right: 12.w, left: 12.w),
        child: Icon(icon, color: AppTheme.colors.primary, size: 22.sp),
      ),
      prefixIconConstraints: BoxConstraints(minWidth: 44.w),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }
}

class _NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }
    final reversed = cleanText.split('').reversed.join();
    final chunks = <String>[];
    for (var i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(reversed.substring(i, end > reversed.length ? reversed.length : end));
    }
    final formatted = chunks.join(' ').split('').reversed.join();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
