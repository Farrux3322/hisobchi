import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/partner_report/partner_report_bloc.dart';
import 'package:hisobchi/application/partner_report/partner_report_event.dart';
import 'package:hisobchi/application/partner_report/partner_report_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/partner_report_model.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/pages/client/report/partner_operations_detail_page.dart';
import 'package:hisobchi/presentation/pages/client/report/partner_summary_list_page.dart';
import 'package:shimmer/shimmer.dart';

import '../../../components/basic_widgets.dart';

class ReportClientMainPage extends StatelessWidget {
  const ReportClientMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PartnerReportBloc(
        repository: PartnerReportRepository(),
      )..add(const LoadPartnerReportEvent()),
      child: const _ReportClientMainPageContent(),
    );
  }
}

class _ReportClientMainPageContent extends StatefulWidget {
  const _ReportClientMainPageContent();

  @override
  State<_ReportClientMainPageContent> createState() => _ReportClientMainPageContentState();
}

class _ReportClientMainPageContentState extends State<_ReportClientMainPageContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Hamkorlar xisoboti', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(12)),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'UZS Hisob'),
                    Tab(text: 'USD Hisob'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<PartnerReportBloc, PartnerReportState>(
        builder: (context, state) {
          if (state.status == Status.loading) {
            return _buildShimmerLoading();
          }

          if (state.status == Status.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Xatolik yuz berdi',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PartnerReportBloc>().add(const LoadPartnerReportEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Qayta urinish'),
                  ),
                ],
              ),
            );
          }

          if (!state.hasData) {
            return const Center(child: Text('Ma\'lumot topilmadi'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReportContent(state.uzsReport!, true),
              _buildReportContent(state.usdReport!, false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportContent(CurrencyReport data, bool isUZS) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PartnerReportBloc>().add(const RefreshPartnerReportEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Jami kirim va chiqim - Row
        Row(
          children: [
            Expanded(
              child: _buildMainStatCard(
                title: 'Kirim',
                value: _formatCurrency(data.debt, isUZS),
                icon: AppIcons.income,
                iconColor: Colors.white,
                backgroundColor: const Color(0xFF4CAF50),
                isUZS: isUZS,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMainStatCard(
                title: 'Chiqim',
                value: _formatCurrency(data.credit, isUZS),
                icon: AppIcons.chiqim,
                iconColor: Colors.white,
                backgroundColor: const Color(0xFFEF5350),
                isUZS: isUZS,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Qoldiq va Hamkorlar soni - Row
        Row(
          children: [
            Expanded(
              child: _buildMainStatCard(
                title: 'Qoldiq',
                value: _formatCurrency(data.balance, isUZS),
                icon: AppIcons.balance,
                iconColor: Colors.white,
                backgroundColor: const Color(0xFF2196F3),
                isUZS: isUZS,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMainStatCard(
                title: 'Hamkorlar',
                value: '${data.partnersCount}',
                icon: AppIcons.clients,
                iconColor: Colors.white,
                backgroundColor: const Color(0xFF9C27B0),
                isUZS: isUZS,
                showCurrency: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Jami operatsiyalar, qarzdorlar, haqdorlar - Row (kichikroq)
        Row(
          children: [
            Expanded(
              child: _buildSmallStatCard(
                title: 'Operatsiyalar',
                count: data.operations.count,
                icon: Icons.sync_alt,
                color: const Color(0xFFFF9800),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartnerOperationsDetailPage(
                        type: 'oparation',
                        currencyTypeId: isUZS ? 1 : 2,
                        title: 'Operatsiyalar',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSmallStatCard(
                title: 'Qarzdorlar',
                count: data.qarzdorlar.count,
                icon: Icons.arrow_upward,
                color: const Color(0xFFFF5722),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartnerSummaryListPage(
                        type: 'qarzdor',
                        currencyTypeId: isUZS ? 1 : 2,
                        title: 'Qarzdorlar',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSmallStatCard(
                title: 'Haqdorlar',
                count: data.xaqdorlar.count,
                icon: Icons.arrow_downward,
                color: const Color(0xFF009688),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartnerSummaryListPage(
                        type: 'xaqdor',
                        currencyTypeId: isUZS ? 1 : 2,
                        title: 'Haqdorlar',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Qarz muddatlari xisoboti title
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.access_time, color: Colors.amber.shade900, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Qarz muddatlari xisoboti',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
            ],
          ),
        ),

        // Qarz muddatlari - Row (uchta ham)
        Row(
          children: [
            Expanded(
              child: _buildDeadlineCard(
                subtitle: '',
                title: "Muddati o'tgan",
                count: data.qarzExpired.count,
                icon: Icons.error_outline,
                color: const Color(0xFFD32F2F),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartnerOperationsDetailPage(
                        type: 'qarz_expired',
                        currencyTypeId: isUZS ? 1 : 2,
                        title: "Muddati o'tgan qarzlar",
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDeadlineCard(
                title: 'Bugun',
                subtitle: '',
                count: data.qarz3Days.count,
                icon: Icons.warning_amber_sharp,
                color: const Color(0xFFFF9800),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartnerOperationsDetailPage(
                        type: data.qarz3Days.type,
                        currencyTypeId: isUZS ? 1 : 2,
                        title: 'Bugun qarzlar',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDeadlineCard(
                title: 'Yaqinlashmoqda',
                subtitle: '(3 kun)',
                count: data.qarz7Days.count,
                icon: Icons.schedule,
                color: const Color(0xFFFFA726),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartnerOperationsDetailPage(
                        type: data.qarz7Days.type,
                        currencyTypeId: isUZS ? 1 : 2,
                        title: '3 kun ichida qarzlar',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    ));
  }

  // Asosiy katta statistika kartlari
  Widget _buildMainStatCard({
    required String title,
    required String value,
    required String icon,
    required Color iconColor,
    required Color backgroundColor,
    bool isUZS = true,
    bool showCurrency = true,
  }) {
    return Container(
      height: 110.h,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: backgroundColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: SvgPicture.asset(icon, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn), width: 24, height: 24),
              ),
              Gap(10.w),
              Text(
                title,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: iconColor.withOpacity(0.9)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: iconColor, letterSpacing: 0.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showCurrency) ...[
                const SizedBox(height: 2),
                Text(
                  _getCurrency(isUZS),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: iconColor.withOpacity(0.8)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Kichik statistika kartlari (operatsiyalar, qarzdorlar, haqdorlar uchun)
  Widget _buildSmallStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700], height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),
                // Count
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(.1)),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, height: 1),
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

  // Qarz muddatlari kartlari - Minimalist Design
  Widget _buildDeadlineCard({
    required String title,
    String? subtitle,
    required int count,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700], height: 1.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // Icon and Count Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color, height: 1),
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

  String _formatCurrency(String value, bool isUZS) {
    if (value.isEmpty) return '0';

    // Parse the string to double
    final number = double.tryParse(value) ?? 0.0;

    // Remove decimal part if it's .00
    final intValue = number.toInt();
    final displayValue = (number == intValue) ? intValue : number;

    // Faqat raqamni formatlash
    final formatted = displayValue.toString().split('.')[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    return formatted;
  }

  String _getCurrency(bool isUZS) {
    return isUZS ? 'UZS' : 'USD';
  }

  // Shimmer loading skeleton
  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main stat cards shimmer
        Row(
          children: [
            Expanded(child: _buildShimmerCard(height: 110.h)),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard(height: 110.h)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildShimmerCard(height: 110.h)),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard(height: 110.h)),
          ],
        ),
        const SizedBox(height: 16),

        // Small stat cards shimmer
        Row(
          children: [
            Expanded(child: _buildShimmerCard(height: 90)),
            const SizedBox(width: 10),
            Expanded(child: _buildShimmerCard(height: 90)),
            const SizedBox(width: 10),
            Expanded(child: _buildShimmerCard(height: 90)),
          ],
        ),
        const SizedBox(height: 20),

        // Title shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Deadline cards shimmer
        Row(
          children: [
            Expanded(child: _buildShimmerCard(height: 100)),
            const SizedBox(width: 10),
            Expanded(child: _buildShimmerCard(height: 100)),
            const SizedBox(width: 10),
            Expanded(child: _buildShimmerCard(height: 100)),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
