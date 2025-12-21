import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../assets/asset_index.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key, this.text1, this.text2, this.icon});
  final String? icon;
  final String? text1;
  final String? text2;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         SvgPicture.asset(icon ?? AppIcons.empty,),
          Gap(30.h),
          Text(
            text1 ?? tr('errors.empty'),
            style: AppTheme.data.textTheme.titleLarge!
                .copyWith(color: Colors.white),
          ),
          Gap(15.h),
          Text(
            text2 ?? tr('errors.empty'),
            style: AppTheme.data.textTheme.titleSmall!.copyWith(color: Colors.grey.shade600, fontSize: 14.sp, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
