import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/application/partner_operations/partner_operations_bloc.dart';
import 'package:hisobchi/application/partner_operations/partner_operations_event.dart';
import 'package:hisobchi/application/partner_operations/partner_operations_state.dart';
import 'package:hisobchi/infrastructure/models/partner_operations_detail_model.dart';
import 'package:hisobchi/infrastructure/repository/partner_operations/partner_operations_repository.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/pages/client/report/widgets/partner_operation_detail_sheet.dart';
import 'package:shimmer/shimmer.dart';

class PartnerOperationsDetailPage extends StatefulWidget {
  final String type;
  final int currencyTypeId;
  final String title;

  const PartnerOperationsDetailPage({super.key, required this.type, required this.currencyTypeId, required this.title});

  @override
  State<PartnerOperationsDetailPage> createState() => _PartnerOperationsDetailPageState();
}

class _PartnerOperationsDetailPageState extends State<PartnerOperationsDetailPage> {
  final ScrollController _scrollController = ScrollController();
  late final PartnerOperationsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PartnerOperationsBloc(PartnerOperationsRepository())..add(LoadOperationsEvent(type: widget.type, currencyTypeId: widget.currencyTypeId));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = _bloc.state;
      if (state.canLoadMore) {
        _bloc.add(LoadMoreOperationsEvent(type: widget.type, currencyTypeId: widget.currencyTypeId, page: state.currentPage + 1));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
          ),
          backgroundColor: AppTheme.colors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.colors.black, size: 20.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<PartnerOperationsBloc, PartnerOperationsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return _buildShimmerLoading();
            }

            if (state.isError && !state.hasData) {
              return _buildErrorWidget(state.errorMessage ?? 'Xatolik yuz berdi');
            }

            if (!state.hasData) {
              return _buildEmptyWidget();
            }

            return RefreshIndicator(
              onRefresh: () async {
                _bloc.add(RefreshOperationsEvent(type: widget.type, currencyTypeId: widget.currencyTypeId));
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w).copyWith(bottom: MediaQuery.of(context).padding.bottom),
                itemCount: state.operations.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.operations.length) {
                    return _buildLoadingMoreIndicator();
                  }
                  return _buildOperationCard(state.operations[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOperationCard(PartnerOperation operation) {
    final isUZS = widget.currencyTypeId == 1;
    final currencyText = isUZS ? 'UZS' : 'USD';
    // User requested to swap Kirim/Chiqim logic
    // Currently isCredit (Kirim) is green, isDebt (Chiqim) is red
    // We swap them so Kirim (incoming) is red and Chiqim (outgoing) is green?
    // Wait, usually Kirim = Income = Green. If they are swapped, it means what is currently Kirim should be Chiqim.
    // However, the model has typeDisplay. Let's just swap the icon and color logic for isCredit.
    final bool isIncoming = !operation.isCredit;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: AppTheme.colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: AppTheme.colors.gray.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOperationDetailSheet(context, operation),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Compact Icon
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(color: isIncoming ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(isIncoming ? Icons.south_west_rounded : Icons.north_east_rounded, color: isIncoming ? const Color(0xFF16A34A) : const Color(0xFFDC2626), size: 20.sp),
                    ),
                    SizedBox(width: 10.w),

                    // Partner and Phone
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            operation.partnerName,
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (operation.partnerPhone != null)
                            Text(
                              _formatPhoneNumber(operation.partnerPhone!),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppTheme.colors.black.withOpacity(.5)),
                            ),
                        ],
                      ),
                    ),

                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isIncoming ? '+' : '-'}${_formatCurrency(operation.remainingAmount)}',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: isIncoming ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                        ),
                        Text(
                          currencyText,
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: (operation.hasReturnDate || operation.isOverdue) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                  children: [
                    if (operation.hasReturnDate || operation.isOverdue) ...[
                      // SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: operation.isOverdue ? const Color(0xFFEF4444).withOpacity(0.05) : const Color(0xFFF59E0B).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              operation.isOverdue ? Icons.notification_important_rounded : Icons.schedule_rounded,
                              size: 12.sp,
                              color: operation.isOverdue ? const Color(0xFFEF4444) : const Color(0xFFD97706),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              operation.isOverdue
                                  ? 'Muddati o\'tgan: ${operation.daysOverdue} kun'
                                  : operation.daysLeft != null
                                  ? (operation.daysLeft == 0 ? 'Bugun qaytarishi kerak' : '${operation.daysLeft} kun qoldi')
                                  : 'Qaytarish sanasi: ${operation.returnDate ?? ''}',
                              style: TextStyle(fontSize: 10.sp, color: operation.isOverdue ? const Color(0xFFB91C1C) : const Color(0xFFB45309), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Text(
                      _formatDate(operation.createdAt),
                      style: TextStyle(fontSize: 12.sp, color: Colors.black87, fontWeight: FontWeight.w500),
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

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(strokeWidth: 2.w),
        ),
      ),
    );
  }

  void _showOperationDetailSheet(BuildContext context, PartnerOperation operation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PartnerOperationDetailSheet(operation: operation),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade400,
            highlightColor: Colors.white,
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(color: AppTheme.colors.gray.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(Icons.receipt_long_rounded, size: 48.sp, color: AppTheme.colors.gray.withOpacity(0.3)),
            ),
            SizedBox(height: 20.h),
            Text(
              'Operatsiyalar topilmadi',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black.withOpacity(0.7)),
            ),
            SizedBox(height: 8.h),
            Text(
              'Ushbu ruknda hozircha hech qanday\nma\'lumot mavjud emas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray.withOpacity(0.6), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), shape: BoxShape.circle),
              child: Icon(Icons.error_outline_rounded, size: 40.sp, color: const Color(0xFFEF4444)),
            ),
            SizedBox(height: 24.h),
            Text(
              'Xatolik yuz berdi',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray.withOpacity(0.6), height: 1.5),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _bloc.add(LoadOperationsEvent(type: widget.type, currencyTypeId: widget.currencyTypeId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text(
                  'Qayta urinish',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(String amount) {
    final value = double.tryParse(amount) ?? 0.0;
    final intValue = value.toInt();
    final formatted = intValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
    return formatted;
  }

  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    // Remove all non-numeric characters
    final clean = phone.replaceAll(RegExp(r'\D'), '');

    // Assume 9 digits if it doesn't start with country code, or 12 digits if it does
    if (clean.length == 9) {
      return '+998 (${clean.substring(0, 2)}) ${clean.substring(2, 5)} ${clean.substring(5, 7)} ${clean.substring(7, 9)}';
    } else if (clean.length == 12 && clean.startsWith('998')) {
      return '+998 (${clean.substring(3, 5)}) ${clean.substring(5, 8)} ${clean.substring(8, 10)} ${clean.substring(10, 12)}';
    }
    return phone;
  }

  String _formatDate(String dateStr) {
    try {
      // Try to parse as ISO 8601 first
      DateTime? date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        // If it fails, try to parse as dd.MM.yyyy format
        final parts = dateStr.split('.');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            date = DateTime(year, month, day);
          }
        }
      }

      if (date == null) return dateStr;

      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return 'Bugun';
      } else if (diff.inDays == 1) {
        return 'Kecha';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} kun oldin';
      } else {
        return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
