import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart' as persistent;

import '../presentation/components/basic_widgets.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key, required this.navBarConfig});

  final persistent.NavBarConfig navBarConfig;

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int selectedIndex = 0;

  final List<String> labels = ["Ma'lumotlar", "Document", "Hisobot", "Profile"];
  List<String> icons = [AppIcons.orders, AppIcons.orders, AppIcons.orders, AppIcons.orders];
  List<String> icons2 = [AppIcons.orders, AppIcons.orders, AppIcons.orders, AppIcons.orders];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Container(
        height: 70.h,
        padding: EdgeInsets.symmetric(vertical: 0.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(labels.length, (index) {
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.navBarConfig.onItemSelected(index);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: isSelected ? 46.w : 0, vertical: 10.h),
                decoration: BoxDecoration(color: isSelected ? AppTheme.colors.red : Colors.transparent, borderRadius: BorderRadius.circular(30.r)),
                child: Row(
                  children: [
                    Container(
                      padding: isSelected ? null : EdgeInsets.all(8),
                      decoration:
                      isSelected ? null : BoxDecoration(border: Border.all(color: AppTheme.colors.gray, width: 1), shape: BoxShape.circle),
                      child: SvgPicture.asset(isSelected?icons[index]:icons2[index],colorFilter: ColorFilter.mode(isSelected ? AppTheme.colors.white : AppTheme.colors.gray,BlendMode.srcIn),),
                      // Icon(icons[index], color: isSelected ? AppTheme.colors.white : AppTheme.colors.grey30)
                    ),
                    if (isSelected) Gap(6.w),
                    if (isSelected) Text(labels[index], style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}