import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/partner_report/partner_report_bloc.dart';
import 'package:hisobchi/application/partner_report/partner_report_event.dart';
import 'package:hisobchi/application/partner_report/partner_report_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/partner_report_model.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/toast/toast.dart';
import 'package:hisobchi/presentation/pages/client/report/partner_operations_detail_page.dart';
import 'package:hisobchi/presentation/pages/client/report/partner_summary_list_page.dart';
import 'package:hisobchi/presentation/pages/client/report/debt_report_detail_page.dart';
import 'package:hisobchi/presentation/pages/client/report/staff_report_page.dart';
import 'package:hisobchi/presentation/pages/client/report/time_report_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hisobchi/application/partner_report/export_excel/export_partner_excel_bloc.dart';
import 'package:hisobchi/application/partner_report/export_excel/export_partner_excel_event.dart';
import 'package:hisobchi/application/partner_report/export_excel/export_partner_excel_state.dart';
import 'package:share_plus/share_plus.dart';

import '../../../components/basic_widgets.dart';

class ReportClientMainPage extends StatelessWidget {
  const ReportClientMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PartnerReportBloc(repository: PartnerReportRepository())..add(const LoadPartnerReportEvent())),
        BlocProvider(create: (context) => ExportPartnerExcelBloc(repository: PartnerReportRepository())),
      ],
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
        title: const Text(
          'Mijozlar hisoboti',
          style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        leading: BackArrowButton(),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Very light gray from the screenshot
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(0),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'UZS Hisob',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: _tabController.index == 0 ? FontWeight.w800 : FontWeight.w500,
                                color: _tabController.index == 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // The || divider
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 2,
                            height: 12,
                            decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            width: 2,
                            height: 12,
                            decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                          ),
                        ],
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(1),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'USD Hisob',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: _tabController.index == 1 ? FontWeight.w800 : FontWeight.w500,
                                color: _tabController.index == 1 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          BlocConsumer<ExportPartnerExcelBloc, ExportPartnerExcelState>(
            listener: (context, state) {
              if (state is ExportPartnerExcelSuccess) {
                SharePlus.instance.share(ShareParams(files: [XFile(state.filePath)], text: 'Mijozlar Hisoboti'));
              } else if (state is ExportPartnerExcelFailure) {
                Toast.showErrorToast(message: state.error);
              }
            },
            builder: (context, state) {
              final isLoading = state is ExportPartnerExcelLoading;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PopupMenuButton<int>(
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  color: Colors.white,
                  icon: isLoading
                      ? SizedBox(width: 24, height: 24, child: CupertinoActivityIndicator(color: AppTheme.colors.primary, radius: 10))
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // color: Colors.grey[100],
                          ),
                          child: Icon(CupertinoIcons.ellipsis_vertical),
                        ),
                  onSelected: (value) {
                    if (value == 1 && !isLoading) {
                      context.read<ExportPartnerExcelBloc>().add(DownloadPartnerExcelRequested());
                    }
                  },
                  constraints: const BoxConstraints(minWidth: 10, maxWidth: 180),
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(
                      value: 1,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_download_outlined, color: AppTheme.colors.primary, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Excel Hisobot',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
                  Text(state.errorMessage ?? 'Xatolik yuz berdi', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
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
          return TabBarView(controller: _tabController, children: [_buildReportContent(state.uzsReport!, true), _buildReportContent(state.usdReport!, false)]);
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
        padding: EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom),
        children: [
          // Jami kirim va chiqim - Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(title: 'Kirim', value: data.debt, icon: AppIcons.income, color: const Color(0xFF16A34A), isUZS: isUZS),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(title: 'Chiqim', value: data.credit, icon: AppIcons.chiqim, color:  const Color(0xFFDC2626), isUZS: isUZS),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Qoldiq (Large) with Partners count badge
          Builder(
            builder: (context) {
              final correctedBalance = -data.balanceAmount;
              final Color qoldiqColor = correctedBalance > 0
                  ? const Color(0xFF4C8CE4) // Mijozlar qarzi (Green)
                  : (correctedBalance < 0
                        ? const Color(0xFF4C8CE4) // Sizning qarzingiz (Red)
                        : const Color(0xFF4C8CE4)); // 0 (Blue)

              return _buildMetricCard(
                title: 'Qoldiq',
                value: correctedBalance.toString(),
                icon: AppIcons.balance,
                color: qoldiqColor,
                isUZS: isUZS,
                isLarge: true,
                partnersCount: data.partnersCount,
                subtitle: correctedBalance < 0 ? '• Sizning qarzingiz' : (correctedBalance > 0 ? '• Mijozlar qarzi' : null),
              );
            },
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
                        builder: (context) => PartnerOperationsDetailPage(type: 'oparation', currencyTypeId: isUZS ? 1 : 2, title: 'Operatsiyalar'),
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
                        builder: (context) => PartnerSummaryListPage(type: 'qarzdor', currencyTypeId: isUZS ? 1 : 2, title: 'Qarzdorlar'),
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
                        builder: (context) => PartnerSummaryListPage(type: 'xaqdor', currencyTypeId: isUZS ? 1 : 2, title: 'Haqdorlar'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(' Hisobot turlari', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          // Qarz muddatlari hisoboti Entry Card
          _buildDebtReportEntryCard(context, data, isUZS),
          const SizedBox(height: 12),

          // Xodimlar hisoboti Entry Card
          _buildStaffReportEntryCard(context),
          const SizedBox(height: 12),

          // Muddat hisoboti Entry Card
          _buildTimeReportEntryCard(context),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Xodimlar hisoboti Entry Card
  Widget _buildTimeReportEntryCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeReportPage()));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.access_time_rounded, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Muddat hisoboti',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700], height: 1.2),
                      ),
                      SizedBox(height: 4),
                      Text('Sana bo\'yicha kirim / chiqim', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Xodimlar hisoboti Entry Card
  Widget _buildStaffReportEntryCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffReportPage()));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.people_alt_outlined, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xodimlar hisoboti',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700], height: 1.2),
                      ),
                      SizedBox(height: 4),
                      Text('Xodimlar bo\'yicha barcha hisobotlar', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Qarz muddatlari hisoboti Entry Card
  Widget _buildDebtReportEntryCard(BuildContext context, CurrencyReport data, bool isUZS) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DebtReportDetailPage(isUZS: isUZS)));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.access_time_rounded, color: Colors.amber.shade900, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qarz muddatlari hisoboti',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700], height: 1.2),
                      ),
                      SizedBox(height: 4),
                      Text('Muddati o\'tgan, bugun va kelgusi qarzlar', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Premium Metric Card (Senior Level Design)
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
    required bool isUZS,
    bool isLarge = false,
    int? partnersCount,
    String? subtitle,
    bool isBordered = false,
  }) {
    final currencyLabel = isUZS ? 'UZS' : 'USD';
    final displayValue = _formatCurrency(value, isUZS);
    final contentColor = isBordered ? color : Colors.white;

    return Container(
      width: isLarge ? double.infinity : null,
      height: isLarge ? null : 0.11.sh,
      padding: EdgeInsets.all(isLarge ? 18 : 14),
      decoration: BoxDecoration(
        color: isBordered ? Colors.white : color,
        borderRadius: BorderRadius.circular(16),
        border: isBordered ? Border.all(color: color.withValues(alpha: 0.5), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isBordered ? 0.1 : 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isLarge
          ? Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: isBordered ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: SvgPicture.asset(icon, colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn), width: 20, height: 20),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: contentColor),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                subtitle,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: contentColor.withValues(alpha: 0.85)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          displayValue,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: contentColor, letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            currencyLabel,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: contentColor.withValues(alpha: 0.8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (partnersCount != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: isBordered ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_alt_outlined, color: contentColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '$partnersCount ta',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: contentColor),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: isBordered ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                      child: SvgPicture.asset(icon, colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn), width: 14, height: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: contentColor),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        displayValue,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: contentColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currencyLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: contentColor.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Kichik statistika kartlari (operatsiyalar, qarzdorlar, haqdorlar uchun)
  Widget _buildSmallStatCard({required String title, required int count, required IconData icon, required Color color, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700], height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),
                // Count
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .1)),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color, height: 1),
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
    final formatted = displayValue.toString().split('.')[0].replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
    return formatted;
  }

  // Shimmer loading skeleton
  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main stat cards shimmer
        Row(
          children: [
            Expanded(child: _buildShimmerCard(height: 100)),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard(height: 100)),
          ],
        ),
        const SizedBox(height: 12),
        _buildShimmerCard(height: 140),
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

        const SizedBox(height: 20),

        // Debt and Staff Report Shimmers
        _buildShimmerCard(height: 80),
        const SizedBox(height: 12),
        _buildShimmerCard(height: 80),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
