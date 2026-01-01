import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/client_report/client_report_bloc.dart';
import 'package:hisobchi/application/client_report/client_report_event.dart';
import 'package:hisobchi/application/client_report/client_report_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/client_report_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/loading/loading.dart';
import 'package:hisobchi/presentation/pages/dashboard/client_report/client_report_three_page.dart';
import 'package:shimmer/shimmer.dart';

class ClientReportTwoPage extends StatefulWidget {
  final ClientReportPartner partner;

  const ClientReportTwoPage({
    super.key,
    required this.partner,
  });

  @override
  State<ClientReportTwoPage> createState() => _ClientReportTwoPageState();
}

class _ClientReportTwoPageState extends State<ClientReportTwoPage> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Default: last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));

    context.read<ClientReportBloc>().add(
          GetSectionTwoReportEvent(
            partnerId: widget.partner.id,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'uz_UZ');
    final formatted = formatter.format(amount.abs());
    final sign = amount < 0 ? '-' : '';
    return '$sign$formatted';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.colors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      if (mounted) {
        context.read<ClientReportBloc>().add(
              GetSectionTwoReportEvent(
                partnerId: widget.partner.id,
                startDate: _startDate,
                endDate: _endDate,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: BlocBuilder<ClientReportBloc, ClientReportState>(
        builder: (context, state) {
          if (state.status == Status.loading) {
            return _buildShimmerLoading();
          }

          if (state.status == Status.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: const Color(0xFFEF4444)),
                  SizedBox(height: 12.h),
                  Text('Xatolik yuz berdi', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8.h),
                  TextButton.icon(
                    onPressed: () => context.read<ClientReportBloc>().add(
                          GetSectionTwoReportEvent(
                            partnerId: widget.partner.id,
                            startDate: _startDate,
                            endDate: _endDate,
                          ),
                        ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Qayta urinish'),
                  ),
                ],
              ),
            );
          }

          if (state.sectionTwoReport == null) {
            return const Center(child: Loading());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPartnerInfo(),
                SizedBox(height: 12.h),
                _buildDateRangeSelector(),
                SizedBox(height: 12.h),
                _buildBalanceCard(
                  'Boshlang\'ich balans',
                  state.sectionTwoReport!.initialBalance,
                  const Color(0xFF64748B),
                ),
                SizedBox(height: 8.h),
                _buildBalanceCard(
                  'Davr debiti',
                  state.sectionTwoReport!.periodDebits,
                  const Color(0xFFEF4444),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => BlocProvider.value(
                          value: context.read<ClientReportBloc>(),
                          child: ClientReportThreePage(
                            partner: widget.partner,
                            type: 'debt',
                            startDate: _startDate,
                            endDate: _endDate,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                _buildBalanceCard(
                  'Davr krediti',
                  state.sectionTwoReport!.periodCredits,
                  const Color(0xFF10B981),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => BlocProvider.value(
                          value: context.read<ClientReportBloc>(),
                          child: ClientReportThreePage(
                            partner: widget.partner,
                            type: 'credit',
                            startDate: _startDate,
                            endDate: _endDate,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                _buildBalanceCard(
                  'Yakuniy balans',
                  state.sectionTwoReport!.finalBalance,
                  AppTheme.colors.primary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20,color: Colors.black,),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Hisobot tafsilotlari', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      centerTitle: true,
    );
  }

  Widget _buildPartnerInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                widget.partner.name.isNotEmpty ? widget.partner.name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.partner.name,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.partner.phone,
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _selectDateRange();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16.sp, color: AppTheme.colors.primary),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, PartnerBalance balance, Color color, {VoidCallback? onTap}) {
    final widget = Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildCurrencyItem('UZS', balance.uzs, color),
              SizedBox(height: 6.h),
              _buildCurrencyItem('USD', balance.usd, color),
            ],
          ),
          if (onTap != null) ...[
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: const Color(0xFF94A3B8)),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildCurrencyItem(String currency, double amount, Color color) {
    final displayAmount = _formatCurrency(amount);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayAmount,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(width: 4.w),
        Text(
          currency,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Partner info shimmer
          Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: const Color(0xFFF8FAFC),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 100.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Date range shimmer
          Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: const Color(0xFFF8FAFC),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Balance cards shimmer
          ...List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Shimmer.fromColors(
                baseColor: const Color(0xFFE2E8F0),
                highlightColor: const Color(0xFFF8FAFC),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 30.w,
                                    height: 10.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    width: 50.w,
                                    height: 15.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 32.h, color: const Color(0xFFE2E8F0), margin: EdgeInsets.symmetric(horizontal: 8.w)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 30.w,
                                    height: 10.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    width: 50.w,
                                    height: 15.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}