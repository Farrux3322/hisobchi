import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppIcons.empty),
          Text("Ma'lumotlar yo’q!",    style: AppTheme.data.textTheme.titleMedium?.copyWith(
            fontSize: 20.sp
          ), textAlign: TextAlign.center),
          Gap(10.h),
          Text("Hozircha bu yerda hech qanday ma'lumot mavjud emas",
              style: AppTheme.data.textTheme.titleMedium?.copyWith(fontSize: 15.sp, color: Colors.grey), textAlign: TextAlign.center),
          // Gap(30.h),
          // MainButton(text: 'Yangilash', onPressed:onTap,
          // backgroundColor: Colors.blue.shade50,)
        ],
      ),
    );
  }
}
