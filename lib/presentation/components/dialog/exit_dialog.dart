import 'package:flutter/material.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/buttons/main_button.dart';
import '../basic_widgets.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      backgroundColor: AppTheme.colors.black.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppIcons.exitIcon),
          SizedBox(height: 20.h),
          Text(
            "profile.exit_dialog_text".tr(),
            textAlign: TextAlign.center,
            style: AppTheme.data.textTheme.bodyMedium!.copyWith(color: Colors.grey),
          ),
          Gap(18.h),
          Row(
            children: [
              Expanded(
                  child: MainButton(
                textColor: AppTheme.colors.white,
                backgroundColor: AppTheme.colors.secondary,
                text: 'profile.back_to'.tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
              Gap(24.w),
              Expanded(
                  child: MainButton(
                textColor: AppTheme.colors.white,
                backgroundColor: AppTheme.colors.red,
                text: "profile.exit".tr(),
                onPressed: () {
                  onPressed();
                },
              )),
            ],
          )
        ],
      ),
    );
  }
}
