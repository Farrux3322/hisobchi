import 'package:flutter/material.dart';
import 'package:ehisob/infrastructure/dto/models/notification/notification_model.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';

class NotificationDetail extends StatelessWidget {
  final NotificationItemModel item;

  const NotificationDetail({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final detail = item.notification;
    final createdAt = item.createdAt != null ? DateTime.parse(item.createdAt!) : DateTime.now();
    final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leadingWidth: 72.w,
        leading: Center(
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Slate-100
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
            ),
          ),
        ),
        title: Text(
          'Tafsilotlar',
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.info_outline_rounded, color: AppTheme.colors.primary, size: 20.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    detail?.title ?? "Xabarnoma",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Color(0xFFF1F5F9), height: 32),
                  Text(
                    detail?.body ?? "",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF334155), // Slate-700
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
