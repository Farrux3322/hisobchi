import 'package:flutter/material.dart';
import 'package:hisobchi/features/payment_schedule/data/models/payment_partner_model.dart';
import 'package:hisobchi/features/payment_schedule/presentation/pages/installment_list_page.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/pages/client/report/installment_report_page.dart';
import 'package:hisobchi/presentation/pages/client/report/partner_installment_report_page.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class InstallmentIndexPage extends StatelessWidget {
  const InstallmentIndexPage({super.key, required this.partnerModel});

  final PartnerModel partnerModel;

  @override
  Widget build(BuildContext context) {
    final partner = PaymentPartnerModel(
      id: partnerModel.id?.toString() ?? '',
      name: partnerModel.name ?? '',
      phone: partnerModel.phone,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackArrowButton(),
        title: Column(
          children: [
            Text(
              "Muddatli to'lov",
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
            ),
            Text(
              partnerModel.name ?? '',
              style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.black, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.w, bottom: 12.h),
              child: Text(
                "Bo'limlar",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            _IndexCard(
              icon: Icons.calendar_month_rounded,
              color: AppTheme.colors.primary,
              title: "Muddatli to'lovga berilganlar",
              subtitle: 'Shu mijozga berilgan barcha rejallar',
              onTap: () => pushScreen(context, screen: InstallmentListPage(partner: partner)),
            ),
            SizedBox(height: 10.h),
            _IndexCard(
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF6366F1),
              title: "Shu mijoz bo'yicha hisobot",
              subtitle: "Mijozning muddatli to'lov hisoboti",
              onTap: () => pushScreen(
                context,
                screen: PartnerInstallmentReportPage(partnerModel: partnerModel),
              ),
            ),
            SizedBox(height: 10.h),
            _IndexCard(
              icon: Icons.people_alt_outlined,
              color: const Color(0xFFF59E0B),
              title: "Jami mijozlar bo'yicha hisobot",
              subtitle: "Barcha mijozlar bo'yicha umumiy hisobot",
              onTap: () => pushScreen(context, screen: const InstallmentReportPage()),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndexCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _IndexCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 22.sp, color: color),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right_rounded, size: 22.sp, color: const Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}
