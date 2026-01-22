import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/infrastructure/dto/models/project/project_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/utils/phone_formatter.dart';

class ProjectCardItem extends StatelessWidget {
  final ProjectModel? projectModel;
  final VoidCallback? onTap;

  const ProjectCardItem({
    super.key,
    required this.projectModel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: projectModel?.deletedAt == null ? const Color(0xFFE2E8F0) : Colors.red.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Project Icon/Image
                    Container(
                      width: 52.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        gradient: (projectModel?.files == null || projectModel!.files!.isEmpty)
                            ? LinearGradient(
                                colors: [
                                  AppTheme.colors.primary,
                                  AppTheme.colors.primary.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.colors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: (projectModel?.files != null && projectModel!.files!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: CachedNetworkImage(
                                imageUrl: projectModel!.files!.first.url ?? '',
                                fit: BoxFit.cover,
                                width: 52.w,
                                height: 52.h,
                                placeholder: (context, url) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.colors.primary,
                                        AppTheme.colors.primary.withValues(alpha: 0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: CupertinoActivityIndicator(
                                      color: Colors.white,
                                      radius: 10,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.colors.primary,
                                        AppTheme.colors.primary.withValues(alpha: 0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.business_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                    ),
                    SizedBox(width: 14.w),

                    // Project Name and Owner
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  projectModel?.projectName ?? '',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (projectModel?.status != null) _buildStatusChip(projectModel!.status!),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            projectModel?.projectOwner ?? '',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Address
                if (projectModel?.address != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.colorF9F9FD,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(AppIcons.address),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            projectModel?.address ?? '',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],

                // Phone and Date
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.colorF9F9FD,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(AppIcons.phone),
                      SizedBox(width: 6.w),
                      Text(
                        PhoneFormatter.formatPhoneNumber(projectModel?.phone ?? ''),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset(AppIcons.date),
                      SizedBox(width: 6.w),
                      Text(
                        projectModel?.createdAt?.split(" ").first ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Jarayonda':
        bgColor = const Color(0xFFFFF3E0);
        textColor = Colors.orange;
        break;
      case 'Muzlatilgan':
        bgColor = const Color(0xFFEEF3FF);
        textColor = Colors.blue;
        break;
      case 'Yakunlangan':
        bgColor = const Color(0xFFE8F5E9);
        textColor = Colors.green;
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}