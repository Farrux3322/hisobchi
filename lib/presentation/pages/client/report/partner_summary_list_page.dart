import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/partner_summary/partner_summary_bloc.dart';
import 'package:hisobchi/application/partner_summary/partner_summary_event.dart';
import 'package:hisobchi/application/partner_summary/partner_summary_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/infrastructure/models/partner_summary_model.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/basic_widgets.dart';
import 'package:hisobchi/presentation/pages/client/client_account_page.dart';
import 'package:shimmer/shimmer.dart';

class PartnerSummaryListPage extends StatelessWidget {
  final String type; // 'xaqdor' or 'qarzdor'
  final int currencyTypeId;
  final String title;

  const PartnerSummaryListPage({
    super.key,
    required this.type,
    required this.currencyTypeId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PartnerSummaryBloc(
        repository: PartnerReportRepository(),
      )..add(LoadPartnerSummaryEvent(
          type: type,
          currencyTypeId: currencyTypeId,
        )),
      child: _PartnerSummaryListPageContent(title: title,currencyTypeId: currencyTypeId,),
    );
  }
}

class _PartnerSummaryListPageContent extends StatefulWidget {
  final String title;
  final int currencyTypeId;
  const _PartnerSummaryListPageContent({required this.title,required this.currencyTypeId});

  @override
  State<_PartnerSummaryListPageContent> createState() => _PartnerSummaryListPageContentState();
}

class _PartnerSummaryListPageContentState extends State<_PartnerSummaryListPageContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PartnerSummaryBloc>().add(LoadMorePartnerSummaryEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 9) {
      return '+998 (${cleaned.substring(0, 2)}) ${cleaned.substring(2, 5)} ${cleaned.substring(5, 7)} ${cleaned.substring(7, 9)}';
    }
    return phone;
  }

  String _formatMoney(String value) {
    try {
      final number = double.tryParse(value) ?? 0.0;
      final formatted = number.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]} ',
          );
      return formatted;
    } catch (e) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DeFocus(
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildSearchField(),
            _buildList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E293B),
      centerTitle: true,
      title: Text(
        widget.title,
        style: TextStyle(
          color: const Color(0xFF1E293B),
          fontWeight: FontWeight.w800,
          fontSize: 18.sp,
          letterSpacing: -0.5,
        ),
      ),
      leading:  BackArrowButton(),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(color: const Color(0xFFF1F5F9), height: 1.h),
      ),
    );
  }

  Widget _buildSearchField() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Ism yoki telefon qidirish...',
              hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp),
              prefixIcon: Padding(
                padding:  EdgeInsets.only(left: 8.0,right: 4),
                child: Icon(Icons.search_rounded, color: AppTheme.colors.primary, size: 22.sp),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, size: 18.sp),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<PartnerSummaryBloc, PartnerSummaryState>(
      builder: (context, state) {
        if (state.status == Status.loading && state.partners.isEmpty) {
          return SliverFillRemaining(child: _buildShimmerLoading());
        }

        if (state.status == Status.error && state.partners.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48.sp, color: Colors.red[300]),
                  SizedBox(height: 16.h),
                  Text(state.errorMessage ?? 'Xatolik yuz berdi'),
                  TextButton(
                    onPressed: () => context.read<PartnerSummaryBloc>().add(LoadPartnerSummaryEvent(
                          type: state.type,
                          currencyTypeId: state.currencyTypeId,
                        )),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            ),
          );
        }

        final filteredPartners = state.partners.where((p) {
          return p.name.toLowerCase().contains(_searchQuery) || p.phone.contains(_searchQuery);
        }).toList();

        if (filteredPartners.isEmpty && state.status == Status.success) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 48.sp, color: Colors.grey[400]),
                  SizedBox(height: 12.h),
                  Text('Ma\'lumot topilmadi', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= filteredPartners.length) {
                  return state.hasReachedMax ? const SizedBox() : _buildLoader();
                }
                return _buildPartnerCard(filteredPartners[index], index);
              },
              childCount: filteredPartners.length + (state.hasReachedMax ? 0 : 1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPartnerCard(PartnerSummaryData partner, int index) {
    final isNegative = partner.balanceDouble < 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_)=>AccountPage(
             partnerModel: PartnerModel(
               id: partner.id,
               name: partner.name,
               phone: partner.phone,
               additionalPhone: partner.additionalPhone,
               mainCurrencyTypeId: partner.mainCurrencyTypeId,
               mainCurrencyTypeName: partner.mainCurrencyTypeName,
               files: partner.files
             ),
           )));
          },
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      partner.name.isNotEmpty ? partner.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: AppTheme.colors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _formatPhoneNumber(partner.phone),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatMoney(partner.balance),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: isNegative ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      partner.mainCurrencyTypeName,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8), // Slate-400
                      ),
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

  Widget _buildLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 8,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Container(
          height: 76.h,
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}
