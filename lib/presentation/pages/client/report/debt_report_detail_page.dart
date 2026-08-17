import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/partner_report/warranty/warranty_period_details_bloc.dart';
import 'package:ehisob/application/partner_report/warranty/warranty_period_details_event.dart';
import 'package:ehisob/application/partner_report/warranty/warranty_period_details_state.dart';
import 'package:ehisob/application/partner_report/warranty/warranty_periods_bloc.dart';
import 'package:ehisob/application/partner_report/warranty/warranty_periods_event.dart';
import 'package:ehisob/application/partner_report/warranty/warranty_periods_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/partner_operations_detail_model.dart';
import 'package:ehisob/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'package:ehisob/presentation/components/back_button.dart';
import 'package:ehisob/presentation/pages/client/report/widgets/partner_operation_detail_sheet.dart';
import 'package:shimmer/shimmer.dart';

import '../../../assets/asset_index.dart';

class DebtReportDetailPage extends StatelessWidget {
  final bool isUZS;

  const DebtReportDetailPage({super.key, required this.isUZS});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WarrantyPeriodsBloc(repository: PartnerReportRepository())..add(const LoadWarrantyPeriodsEvent())),
        BlocProvider(create: (_) => WarrantyPeriodDetailsBloc(repository: PartnerReportRepository())),
      ],
      child: _DebtReportDetailView(initialIsUZS: isUZS),
    );
  }
}

class _DebtReportDetailView extends StatefulWidget {
  final bool initialIsUZS;

  const _DebtReportDetailView({required this.initialIsUZS});

  @override
  State<_DebtReportDetailView> createState() => _DebtReportDetailViewState();
}

class _DebtReportDetailViewState extends State<_DebtReportDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTypeIndex = 0; // 0: qarz_expired, 1: qarz_today, 2: qarz_3_days

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIsUZS ? 0 : 1);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Tab changed, reload lists
        _loadDetails();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  void _loadDetails() {
    final currencyTypeId = _tabController.index == 0 ? 1 : 2;
    String type;
    switch (_selectedTypeIndex) {
      case 0:
        type = 'qarz_expired';
        break;
      case 1:
        type = 'qarz_today';
        break;
      case 2:
        type = 'qarz_3_days';
        break;
      default:
        type = 'qarz_expired';
        break;
    }

    context.read<WarrantyPeriodDetailsBloc>().add(LoadWarrantyPeriodDetailsEvent(type: type, currencyTypeId: currencyTypeId));
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels >= notification.metrics.maxScrollExtent * 0.9) {
        context.read<WarrantyPeriodDetailsBloc>().add(LoadMoreWarrantyPeriodDetailsEvent());
      }
    }
    return false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(controller: _tabController, children: [_buildContent(isUZS: true), _buildContent(isUZS: false)]),
          ),
        ],
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const BackArrowButton(),
      centerTitle: true,
      title: const Text(
        'Qarz muddatlari',
        style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ─── Tab var ──────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9), // Very light gray from the screenshot
          borderRadius: BorderRadius.circular(12.r),
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
                      fontSize: 15.sp,
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
                Container(width: 2.w, height: 12.h, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r))),
                SizedBox(width: 2.w),
                Container(width: 2.w, height: 12.h, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r))),
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
                      fontSize: 15.sp,
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
  }

  // ─── Content ──────────────────────────────────────────────────────────────
  Widget _buildContent({required bool isUZS}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Cards Dashboard
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: BlocBuilder<WarrantyPeriodsBloc, WarrantyPeriodsState>(
            builder: (context, state) {
              if (state.status == Status.loading || state.status == Status.initial) {
                return _buildTopCardsShimmer();
              }
              if (state.status == Status.error) {
                return _buildTopCardsError(state.errorMessage ?? "Xatolik yuz berdi");
              }

              final currencyData = isUZS ? state.response?.result.uzs : state.response?.result.usd;
              if (currencyData == null) {
                return _buildTopCardsError("Ma'lumot topilmadi");
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildDashboardCard(index: 0, title: "Muddati\no'tgan", count: currencyData.qarzExpired.count, tailText: "", baseColor: const Color(0xFFFF6B6B)),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildDashboardCard(index: 1, title: "Bugun\n", count: currencyData.qarzToday.count, tailText: "", baseColor: const Color(0xFFFF9F43)),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildDashboardCard(index: 2, title: "Yaqin-\nlashmoqda", count: currencyData.qarz3Days.count, tailText: "3 kun ichida", baseColor: const Color(0xFF2ED573)),
                  ),
                ],
              );
            },
          ),
        ),

        // Section Title
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
          child: BlocBuilder<WarrantyPeriodDetailsBloc, WarrantyPeriodDetailsState>(
            builder: (context, state) {
              String titlePrefix = "Muddati o'tgan";
              if (_selectedTypeIndex == 1) titlePrefix = "Bugun";
              if (_selectedTypeIndex == 2) titlePrefix = "Yaqinlashmoqda";

              if (state.status == Status.loading && state.operations.isEmpty) {
                return Text(
                  "$titlePrefix...",
                  style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp, fontWeight: FontWeight.w800),
                );
              }

              return Text(
                "$titlePrefix — ${state.operations.length} ta",
                style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              );
            },
          ),
        ),

        // Paginated List
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: BlocBuilder<WarrantyPeriodDetailsBloc, WarrantyPeriodDetailsState>(
              builder: (context, state) {
                if (state.status == Status.loading && state.operations.isEmpty) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: 4,
                    itemBuilder: (_, __) => _buildListItemShimmer(),
                  );
                }

                if (state.operations.isEmpty) {
                  return Center(
                    child: Text(
                      'Ma\'lumot topilmadi',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + MediaQuery.of(context).padding.bottom),
                  itemCount: state.operations.length + (state.statusMore == Status.loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.operations.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _buildDebtCard(state.operations[index], isUZS ? 'UZS' : 'USD');
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── Dashboard Cards ──────────────────────────────────────────────────────
  Widget _buildDashboardCard({required int index, required String title, required int count, required String tailText, required Color baseColor}) {
    final bool isSelected = _selectedTypeIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTypeIndex = index;
        });
        _loadDetails();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : baseColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected ? [BoxShadow(color: baseColor.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
          border: Border.all(color: Colors.white.withValues(alpha:  isSelected ? 0.3 : 0.0), width: isSelected ? 1 : 0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 1), fontSize: 11.sp, fontWeight: FontWeight.bold, height: 1.25),
              maxLines: 2,
            ),
            SizedBox(height: 12.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(color: isSelected ? Colors.white : Colors.white.withValues(alpha:1), fontSize: 20.sp, fontWeight: FontWeight.w900, height: 1.0),
                ),
                SizedBox(height: 4.h),
                Text(
                  tailText,
                  style: TextStyle(color: isSelected ? Colors.white.withValues(alpha: 0.85) : Colors.white.withValues(alpha:1), fontSize: 9.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCardsShimmer() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 10.w : 0),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFE2E8F0),
              highlightColor: const Color(0xFFF1F5F9),
              child: Container(
                height: 130.h,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCardsError(String message) {
    return Container(
      width: double.infinity,
      height: 130.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: const Color(0xFFEF4444), size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(color: const Color(0xFF991B1B), fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ─── List Item (Debt Card) ────────────────────────────────────────────────
  Widget _buildDebtCard(PartnerOperation op, String currency) {
    final initials = op.partnerName.isNotEmpty ? op.partnerName.substring(0, 1).toUpperCase() : '?';
    // Use second letter for initials if available
    final twoInitials = op.partnerName.length > 1 ? op.partnerName.substring(0, 2).toUpperCase() : initials;

    // Depending on what is selected, color styling slightly adapts or just stick to red border.
    Color themeColor = const Color(0xFFFF6B6B); // Default Red
    String typePillLabel = '';

    if (_selectedTypeIndex == 0) {
      themeColor = const Color(0xFFFF6B6B);
      final days = op.daysOverdue ?? 0;
      typePillLabel = "$days kun o'tdi";
    } else if (_selectedTypeIndex == 1) {
      themeColor = const Color(0xFFFF9F43);
      typePillLabel = "Bugun muddati";
    } else if (_selectedTypeIndex == 2) {
      themeColor = const Color(0xFF2ED573);
      final days = op.daysLeft ?? 3;
      typePillLabel = "$days kun qoldi";
    }

    // Usually the amount is remaining_amount in the response.
    // In PartnerOperation, amount could map to remainingAmount or just amount depending on our model structure.
    // Assuming backend returns it properly.
    final amountDouble = op.amount;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => PartnerOperationDetailSheet(operation: op),
            );
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Border Accent
                Container(width: 4.w, color: themeColor),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar (Soft Background, Colored Text)
                        Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            twoInitials,
                            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                        ),
                        SizedBox(width: 14.w),

                        // Title & Phone & Pill
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                op.partnerName,
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (op.partnerPhone != null && op.partnerPhone!.isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  _formatPhone(op.partnerPhone),
                                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                                ),
                              ],
                              SizedBox(height: 8.h),
                              // Pill
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                                child: Text(
                                  typePillLabel,
                                  style: TextStyle(color: themeColor, fontSize: 11.sp, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatDouble(amountDouble),
                              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              currency,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItemShimmer() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      height: 90.h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: Row(
          children: [
            Container(width: 4.w, color: Colors.white),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Row(
                  children: [
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: double.infinity, height: 16.h, color: Colors.white),
                          SizedBox(height: 6.h),
                          Container(width: 100.w, height: 12.h, color: Colors.white),
                          SizedBox(height: 8.h),
                          Container(
                            width: 80.w,
                            height: 20.h,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(width: 60.w, height: 18.h, color: Colors.white),
                        SizedBox(height: 6.h),
                        Container(width: 30.w, height: 12.h, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Formatting Helper ────────────────────────────────────────────────────
  String _formatDouble(double amount) {
    if (amount == 0) return '0';
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(amount.abs()).replaceAll(',', ' ');
  }

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 9) {
      return '+998 (${digits.substring(0, 2)}) ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)}';
    } else if (digits.length == 12 && digits.startsWith('998')) {
      final local = digits.substring(3);
      return '+998 (${local.substring(0, 2)}) ${local.substring(2, 5)} ${local.substring(5, 7)} ${local.substring(7, 9)}';
    }
    return phone; // Return original if it doesn't match standard UZ format
  }
}
