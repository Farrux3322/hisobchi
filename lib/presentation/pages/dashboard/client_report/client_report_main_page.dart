import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/client_report/client_report_bloc.dart';
import 'package:hisobchi/application/client_report/client_report_event.dart';
import 'package:hisobchi/application/client_report/client_report_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/client_report_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
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
  String _selectedCurrency = 'UZS'; // 'UZS' or 'USD'

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

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    
    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    
    // If starts with 998, use it; otherwise assume it's local number
    if (digits.startsWith('998')) {
      digits = digits.substring(3); // Remove country code
    }
    
    // Format: +998 (XX) XXX XX XX
    if (digits.length >= 9) {
      return '+998 (${digits.substring(0, 2)}) ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)}';
    }
    
    // Return original if can't format
    return phone;
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
                _buildCurrencySwitcher(),
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

  Widget _buildCurrencySwitcher() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildCurrencyTab('UZS Hisob', _selectedCurrency == 'UZS'),
          _buildCurrencyTab('USD Hisob', _selectedCurrency == 'USD'),
        ],
      ),
    );
  }

  Widget _buildCurrencyTab(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCurrency = label.contains('UZS') ? 'UZS' : 'USD'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(ClientReportState state) {
    if (state.partners.isEmpty) return const SizedBox.shrink();

    final isUzs = _selectedCurrency == 'UZS';
    double totalKirim = 0;
    double totalChiqim = 0;

    for (var p in state.partners) {
      final balance = isUzs ? p.balance.uzs : p.balance.usd;
      if (balance > 0) {
        totalKirim += balance;
      } else if (balance < 0) {
        totalChiqim += balance.abs();
      }
    }

    final double totalQoldiq = totalKirim - totalChiqim;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Row(
            children: [
              _buildMetricCard(
                title: 'Kirim',
                value: totalKirim,
                color: const Color(0xFF10B981),
                icon: Icons.add_circle_outline,
              ),
              SizedBox(width: 12.w),
              _buildMetricCard(
                title: 'Chiqim',
                value: totalChiqim,
                color: const Color(0xFFEF4444),
                icon: Icons.remove_circle_outline,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildMetricCard(
            title: 'Qoldiq',
            value: totalQoldiq,
            color: const Color(0xFF3B82F6),
            icon: Icons.account_balance_wallet_outlined,
            isBalance: true,
            isLarge: true,
            partnersCount: state.partners.length,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double value,
    required Color color,
    required IconData icon,
    bool isBalance = false,
    bool isLarge = false,
    int? partnersCount,
  }) {
    final currencyLabel = _selectedCurrency;
    final displayValue = _formatCurrency(value);

    return Container(
      width: isLarge ? double.infinity : null,
      height: isLarge ? null : 100.h,
      padding: EdgeInsets.all(isLarge ? 18.w : 14.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
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
                        Icon(icon, color: Colors.white, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          title,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      value < 0 ? '• Sizning qarzingiz' : '• Sizning haqdorligingiz',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          displayValue,
                          style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(width: 6.w),
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Text(
                            currencyLabel,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.7)),
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
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_alt_outlined, color: Colors.white, size: 12.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '$partnersCount ta',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white),
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
                    Icon(icon, color: Colors.white, size: 14.sp),
                    SizedBox(width: 6.w),
                    Text(
                      title,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        displayValue,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currencyLabel,
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ],
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
                    _formatPhone(partner.phone),
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
