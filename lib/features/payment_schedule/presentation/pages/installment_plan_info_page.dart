import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/full_screen_photo.dart';
import '../../data/models/installment_plan_model.dart';
import '../../data/models/enums.dart';

class InstallmentPlanInfoPage extends StatelessWidget {
  final InstallmentPlanModel plan;

  const InstallmentPlanInfoPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');
    final currLabel = plan.currency == PaymentCurrency.uzs ? 'UZS' : 'USD';

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.white,
        elevation: 0,
        leading: const BackArrowButton(),
        centerTitle: true,
        title: Text(
          "Batafsil ma'lumot",
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16.r),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ─── Main Info Card ─────────────────────────────────────────────────
                _InfoContainer(
                  title: "",
                  child: Column(
                    children: [
                      _DetailRow(label: "Mijoz", value: plan.partnerName, icon: Icons.person_rounded),
                      _DetailRow(
                        label: "Jami summa",
                        value: "${fmt.format(plan.totalAmount).replaceAll(',', ' ')} $currLabel",
                        icon: Icons.account_balance_wallet_rounded,
                        valueColor: AppTheme.colors.primary,
                      ),
                      _DetailRow(label: "Boshlanish sanasi", value: plan.startDate ?? '-', icon: Icons.calendar_today_rounded),
                      _DetailRow(label: "Muddati", value: "${plan.totalCount} oy", icon: Icons.timelapse_rounded),
                      _DetailRow(label: "To'lov turi", value: plan.scheduleType.label, icon: Icons.style_rounded),
                      if (plan.activity != null) _DetailRow(label: "Yaratuvchi", value: plan.activity!, icon: Icons.work_rounded),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // ─── Note Section ───────────────────────────────────────────────────
                if (plan.note != null && plan.note!.isNotEmpty) ...[
                  _InfoContainer(
                    title: "Izoh",
                    child: Text(
                      plan.note!,
                      style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black, height: 1.5),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // ─── Files Section Header ───────────────────────────────────────────
                if (plan.files.isNotEmpty) ...[
                  Text(
                    "Fayllar",
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
                  ),
                  SizedBox(height: 10.h),
                ],
              ]),
            ),
          ),

          // ─── Files Grid Section ─────────────────────────────────────────────
          if (plan.files.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 32.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.r,
                  mainAxisSpacing: 12.r,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final file = plan.files[index];
                    return _FileCard(file: file, allFiles: plan.files);
                  },
                  childCount: plan.files.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: AppTheme.colors.background, borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, size: 16.r, color: AppTheme.colors.gray),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w500)),
                Text(
                  value,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: valueColor ?? AppTheme.colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final InstallmentFileModel file;
  final List<InstallmentFileModel> allFiles;

  const _FileCard({required this.file, required this.allFiles});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.colors.divider.withValues(alpha: 0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: file.isImage
                    ? CachedNetworkImage(
                        imageUrl: file.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary)),
                        errorWidget: (context, url, error) => Icon(Icons.image_not_supported_rounded, color: AppTheme.colors.gray),
                      )
                    : Container(
                        color: AppTheme.colors.background,
                        child: Icon(Icons.insert_drive_file_rounded, size: 32.r, color: AppTheme.colors.primary),
                      ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                color: AppTheme.colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        file.isImage ? "Rasm" : "Fayl",
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(file.isImage ? Icons.zoom_in_rounded : Icons.download_rounded, size: 14.r, color: AppTheme.colors.gray),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) async {
    if (file.isImage) {
      final images = allFiles.where((f) => f.isImage).map((f) => ImageItem(path: f.url, isNetwork: true, id: f.id.toString())).toList();
      final initialIndex = images.indexWhere((img) => img.path == file.url);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerPage(
            images: images,
            initialIndex: initialIndex != -1 ? initialIndex : 0,
          ),
        ),
      );
    } else {
      final uri = Uri.parse(file.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
