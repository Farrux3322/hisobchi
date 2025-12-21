import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';

class WarningNotRegisterDialog extends StatelessWidget {
  const WarningNotRegisterDialog({
    super.key,
    required this.onPressed,
    required this.phone,
  });

  final VoidCallback onPressed;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppIcons.warningYellow,
              height: 0.15.sh,
            ),
            Gap(20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                tr('sign_in.not_register', namedArgs: {'phone': phone}),
                textAlign: TextAlign.center,
                style: AppTheme.data.textTheme.bodyMedium,
              ),
            ),
            Gap(25.h),
            ElevatedButton(onPressed: (){
              context.pop();
              onPressed();
            }, child: Text('sign_in.register'.tr())),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'sign_in.return_home'.tr(),
                style: AppTheme.data.textTheme.bodyMedium!.copyWith(color: AppTheme.colors.primary),
              ),
            )
          ],
        ),
      ),
    );
  }
}
