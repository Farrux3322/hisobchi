import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';


class UpdateAppDialog extends StatelessWidget {
  const UpdateAppDialog({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: SizedBox(
        height: 0.44.sh,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0.03.sh, horizontal: 0.05.sw),
          child: Column(
            children: [
              Text(
                'Yangilanish mavjud',
                style: AppTheme.data.textTheme.titleSmall!.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
              ),
              Gap(8.h),
              Text(
                "Dasturga qo'shimcha imkoniyatlar qo'shildi uni yangilab oling!",
                textAlign: TextAlign.center,
                style: AppTheme.data.textTheme.titleSmall!.copyWith(fontSize: 10.sp, fontWeight: FontWeight.w400, color: AppTheme.colors.black),
              ),
              Gap(20.h),
              Lottie.asset(
                "assets/icons/update_app.json",
                height: 0.2.sh,
                fit: BoxFit.fitHeight,
                repeat: false,
              ),
              Gap(15.h),
              SizedBox(
                child: Row(
                  children: [
                    const SizedBox(),
                    Gap(10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (Platform.isAndroid) {
                            _launchUrl();
                          } else if (Platform.isIOS) {
                            _launchUrlIos();
                          } else {
                            if (kDebugMode) {
                              print("Error Platform!");
                            }
                          }

                          // Navigator.pop(context);
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppTheme.colors.primary),
                            child: Center(
                              child: Text(
                                "Yangilash",
                                style: AppTheme.data.textTheme.labelSmall!.copyWith(color: AppTheme.colors.white,fontSize: 16.sp, fontWeight: FontWeight.w500),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

Future<void> _launchUrl() async {
  final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.alpha.hisobchi&hl=en');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> _launchUrlIos() async {
  final Uri url = Uri.parse('https://apps.apple.com/uz/app/e-hisob/id6758664453');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
}
