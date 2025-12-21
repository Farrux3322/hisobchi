import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/assets/res/app_icons.dart';
import 'package:lottie/lottie.dart';


class AreaOutDialog extends StatelessWidget {
  const AreaOutDialog({super.key, required this.onTap, required this.title});

  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 0.2.sw),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(20.h),
              Lottie.asset(AppIcons.locationLottie),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.data.textTheme.titleSmall!.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400),
              ),
              Gap(20.h),
              // AppButton(
              //   onTab: onTap,
              //   child: Container(
              //     width: double.infinity,
              //     padding: EdgeInsets.symmetric(vertical: 10.h),
              //     child: Center(
              //       child: Text(
              //         "retry".tr(),
              //         style: AppTheme.data.textTheme.labelSmall!.copyWith(color: AppTheme.colors.white, fontWeight: FontWeight.w500),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
