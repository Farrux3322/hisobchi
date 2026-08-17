import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/dashboard/dashboard_bloc.dart';
import 'package:ehisob/application/file_upload/file_upload_bloc.dart';
import 'package:ehisob/features/payment_schedule/presentation/pages/payment_schedule_page.dart';
import 'package:ehisob/infrastructure/repository/file_upload/file_upload_repository.dart';
import 'package:ehisob/infrastructure/services/permission_extension.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/toast/toast.dart';
import '../../client/client_add_page.dart';
import '../../client/report/report_client_main_page.dart';
import '../../project/project_add_page.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tezkor amallar',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.colors.black,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Xizmatlar',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildActionItem(
                  context: context,
                  label: '+ Mijoz',
                  icon: Icons.person_add_alt_1_rounded,
                  color: const Color(0xFF4F46E5),
                  bgColor: const Color(0xFFEEF2FF),
                  onTap: () {
                    if (!context.hasPermission('partners.create')) {
                      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => FileUploadBloc(repository: FileUploadRepository()),
                          child: const ClientAddPage(),
                        ),
                      ),
                    ).then((_) {
                      if (context.mounted) {
                        context.read<DashboardBloc>().add(const LoadDashboard());
                      }
                    });
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionItem(
                  context: context,
                  label: '+ Loyiha',
                  icon: Icons.create_new_folder_rounded,
                  color: const Color(0xFF0284C7),
                  bgColor: const Color(0xFFF0F9FF),
                  onTap: () {
                    if (!context.hasPermission('projects.create')) {
                      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProjectAddPage()),
                    ).then((_) {
                      if (context.mounted) {
                        context.read<DashboardBloc>().add(const LoadDashboard());
                      }
                    });
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionItem(
                  context: context,
                  label: 'Hisobot',
                  icon: Icons.analytics_rounded,
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                  onTap: () {
                    if (!context.hasPermission('report_partners.view')) {
                      Toast.showWarningToast(message: 'Sizda bunday huquq yo\'q');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportClientMainPage()),
                    );
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionItem(
                  context: context,
                  label: 'Grafik',
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFFFBEB),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentSchedulePage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 19.sp),
              ),
              SizedBox(height: 6.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
