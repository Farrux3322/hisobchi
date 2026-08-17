import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ehisob/infrastructure/dto/models/project/project_model.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/utils/phone_formatter.dart';
import 'package:shimmer/shimmer.dart';

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
    final bool isDeleted = projectModel?.deletedAt != null;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDeleted ? Colors.red.shade200 : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Icon/Image
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withValues(alpha: 0.15),
                            AppTheme.colors.primary.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: (projectModel?.files != null && projectModel!.files!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: CachedNetworkImage(
                                imageUrl: projectModel!.files!.first.url ?? '',
                                fit: BoxFit.cover,
                                width: 48.r,
                                height: 48.r,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: const Color(0xFFF1F5F9),
                                  highlightColor: Colors.white,
                                  child: Container(width: 48.r, height: 48.r, color: Colors.white),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Icon(
                                    Icons.business_center_rounded,
                                    color: const Color(0xFF6366F1),
                                    size: 22.sp,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.business_center_rounded,
                                color: const Color(0xFF6366F1),
                                size: 22.sp,
                              ),
                            ),
                    ),
                    SizedBox(width: 12.w),

                    // Project Name, Owner & Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  projectModel?.projectName ?? 'Nomsiz loyiha',
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (projectModel?.status != null)
                                _buildStatusChip(projectModel!.status!),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            projectModel?.projectOwner ?? 'Buyurtmachi ko\'rsatilmagan',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Address row
                if ((projectModel?.address ?? '').isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(AppIcons.address, width: 12.sp, height: 12.sp),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            projectModel?.address ?? '',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 10.h),

                // Phone and Date Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if ((projectModel?.phone ?? '').isNotEmpty)
                      Row(
                        children: [
                          SvgPicture.asset(AppIcons.phone, width: 12.sp, height: 12.sp),
                          SizedBox(width: 5.w),
                          Text(
                            PhoneFormatter.formatPhoneNumber(projectModel?.phone ?? ''),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.date, width: 12.sp, height: 12.sp),
                        SizedBox(width: 5.w),
                        Text(
                          projectModel?.createdAt?.split(" ").first ?? '',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
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

    switch (status.toLowerCase()) {
      case 'jarayonda':
      case 'in_progress':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF3B82F6);
        break;
      case 'to\'xtatilgan':
      case 'muzlatilgan':
      case 'frozen':
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFF59E0B);
        break;
      case 'yakunlangan':
      case 'tugallangan':
      case 'completed':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF10B981);
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}