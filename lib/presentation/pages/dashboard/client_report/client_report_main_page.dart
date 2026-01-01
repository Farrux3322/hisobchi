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
import 'package:hisobchi/presentation/pages/dashboard/client_report/client_report_two_page.dart';
import 'package:shimmer/shimmer.dart';

class ClientReportMainPage extends StatefulWidget {
  const ClientReportMainPage({super.key});

  @override
  State<ClientReportMainPage> createState() => _ClientReportMainPageState();
}

class _ClientReportMainPageState extends State<ClientReportMainPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<ClientReportPartner> _filteredPartners = [];
  String _selectedFilter = 'all';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _selectedFilter = 'all';
              break;
            case 1:
              _selectedFilter = 'debt';
              break;
            case 2:
              _selectedFilter = 'credit';
              break;
          }
          _filterPartners();
        });
      }
    });
    _searchController.addListener(_filterPartners);
    context.read<ClientReportBloc>().add(const GetSectionOneReportEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPartners() {
    final state = context.read<ClientReportBloc>().state;
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredPartners = state.partners.where((partner) {
        final matchesSearch = query.isEmpty || partner.name.toLowerCase().contains(query) || partner.phone.toLowerCase().contains(query);

        final balanceStatus = partner.balance.getBalanceStatus();
        final matchesFilter =
            _selectedFilter == 'all' ||
            (_selectedFilter == 'debt' && balanceStatus == 'debt') ||
            (_selectedFilter == 'credit' && balanceStatus == 'credit') ||
            (_selectedFilter == 'neutral' && balanceStatus == 'neutral');

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'uz_UZ');
    final formatted = formatter.format(amount.abs());
    final sign = amount < 0 ? '-' : '';
    return '$sign$formatted';
  }

  Color _getBalanceColor(String status) {
    switch (status) {
      case 'debt':
        return const Color(0xFFEF4444);
      case 'credit':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: BlocConsumer<ClientReportBloc, ClientReportState>(
        listener: (context, state) {
          if (state.status == Status.success) {
            _filterPartners();
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ClientReportBloc>().add(const RefreshSectionOneReportEvent());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppTheme.colors.primary,
            child: Column(
              children: [
                _buildStats(state),
                // _buildSearchBar(),
                _buildFilters(),
                Expanded(
                  child: TabBarView(controller: _tabController, children: [_buildPartnersList(state), _buildPartnersList(state), _buildPartnersList(state)]),
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
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black54),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Mijozlar hisoboti', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      centerTitle: true,
    );
  }

  Widget _buildStats(ClientReportState state) {
    if (state.partners.isEmpty) return const SizedBox.shrink();

    final total = state.partners.length;
    final debt = state.partners.where((p) => p.balance.hasDebt()).length;
    final credit = state.partners.where((p) => !p.balance.hasDebt() && (p.balance.uzs > 0 || p.balance.usd > 0)).length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Jami', total.toString(), AppTheme.colors.primary)),
          Container(width: 1, height: 30.h, color: const Color(0xFFE2E8F0)),
          Expanded(child: _buildStatItem('Qarz', debt.toString(), const Color(0xFFEF4444))),
          Container(width: 1, height: 30.h, color: const Color(0xFFE2E8F0)),
          Expanded(child: _buildStatItem('Haqdor', credit.toString(), const Color(0xFF10B981))),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: color),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Qidirish...',
          hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _searchController.clear()) : null,
        ),
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10.r)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.colors.primary,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
        indicatorPadding: EdgeInsets.all(4.w),
        tabs: const [
          Tab(text: 'Barchasi'),
          Tab(text: 'Qarzdorlar'),
          Tab(text: 'Haqdorlar'),
        ],
      ),
    );
  }

  Widget _buildPartnersList(ClientReportState state) {
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
            Text(
              'Xatolik yuz berdi',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            TextButton.icon(onPressed: () => context.read<ClientReportBloc>().add(const GetSectionOneReportEvent()), icon: const Icon(Icons.refresh), label: const Text('Qayta urinish')),
          ],
        ),
      );
    }

    if (_filteredPartners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48.sp, color: const Color(0xFF94A3B8)),
            SizedBox(height: 12.h),
            Text(
              'Mijoz topilmadi',
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + MediaQuery.of(context).padding.bottom),
      itemCount: _filteredPartners.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) => _buildPartnerCard(_filteredPartners[index]),
    );
  }

  Widget _buildPartnerCard(ClientReportPartner partner) {
    final status = partner.balance.getBalanceStatus();
    final statusColor = _getBalanceColor(status);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => BlocProvider.value(
              value: context.read<ClientReportBloc>(),
              child: ClientReportTwoPage(partner: partner),
            ),
          ),
        );
      },
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
              decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
              child: Center(
                child: Text(
                  partner.name.isNotEmpty ? partner.name[0].toUpperCase() : '?',
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
                    partner.name,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    partner.phone,
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (partner.balance.uzs != 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatCurrency(partner.balance.uzs),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: statusColor),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'UZS',
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: statusColor.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                if (partner.balance.usd != 0) ...[
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatCurrency(partner.balance.usd),
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'USD',
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: statusColor.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ],
                if (partner.balance.uzs == 0 && partner.balance.usd == 0)
                  Text(
                    '0',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: statusColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      itemCount: 10,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) => Shimmer.fromColors(
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14.h,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 100.w,
                      height: 12.h,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 60.w,
                    height: 13.h,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
