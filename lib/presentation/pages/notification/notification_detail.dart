
import 'package:flutter/material.dart';
import 'package:hisobchi/infrastructure/models/notification_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/assets/res/app_icons.dart';

import '../../components/basic_widgets.dart';

class NotificationDetail extends StatelessWidget {
  final NotificationModel notificationModel;

  const NotificationDetail({
    super.key,
    required this.notificationModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 29, 35, 1),
      appBar: AppBar(
        title: Text(notificationModel.title ?? '', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: 16.sp)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: 55.w,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.0, //
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: SvgPicture.asset(
                    AppIcons.arrowBack,
                    colorFilter: ColorFilter.mode(AppTheme.colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(15.w, 20.h, 15.w, 10.h),
              child: Text(
                notificationModel.date ?? 'notifications.noDate'.tr(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, letterSpacing: 0.5, fontSize: 14.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0.w),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: const Color.fromRGBO(32, 37, 48, 1), borderRadius: BorderRadius.circular(6.r)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 10.h),
                  child: Text(
                    notificationModel.body ?? 'notifications.noInformation'.tr(),
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400, letterSpacing: 0.5, fontSize: 14.sp, height: 1.5.h),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
