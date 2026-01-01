import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/client_report/client_report_bloc.dart';
import 'package:hisobchi/application/client_report/client_report_event.dart';
import 'package:hisobchi/application/client_report/client_report_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/client_report_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:shimmer/shimmer.dart';

class ClientReportThreePage extends StatefulWidget {
  final ClientReportPartner partner;
  final String type; // 'debt' or 'credit'
  final DateTime startDate;
  final DateTime endDate;

  const ClientReportThreePage({
    super.key,
    required this.partner,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ClientReportThreePage> createState() => _ClientReportThreePageState();
}

class _ClientReportThreePageState extends State<ClientReportThreePage> {
  @override
  void initState() {
    super.initState();
    context.read<ClientReportBloc>().add(
          GetSectionThreeReportEvent(
            partnerId: widget.partner.id,
            startDate: widget.startDate,
            endDate: widget.endDate,
            type: widget.type,
          ),
        );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'uz_UZ');
    return formatter.format(amount);
  }

  String _formatDate(String dateStr) {
    // Format: "24.12.2025 10:50:07"
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split(' ');
    if (parts.isEmpty) return dateStr;
    return parts[0]; // Return only date part
  }

  Color _getTypeColor() {
    return widget.type == 'debt' ? const Color(0xFFEF4444) : const Color(0xFF10B981);
  }

  String _getTypeLabel() {
    return widget.type == 'debt' ? 'Qarz operatsiyalari' : 'Kredit operatsiyalari';
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
                          GetSectionThreeReportEvent(
                            partnerId: widget.partner.id,
                            startDate: widget.startDate,
                            endDate: widget.endDate,
                            type: widget.type,
                          ),
                        ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Qayta urinish'),
                  ),
                ],
              ),
            );
          }

          if (state.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(height: 12.h),
                  Text('Operatsiyalar topilmadi', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF64748B))),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildTransactionsList(state.transactions)),
            ],
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
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(_getTypeLabel(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.all(16.w),
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
              color: _getTypeColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              widget.type == 'debt' ? Icons.arrow_upward : Icons.arrow_downward,
              color: _getTypeColor(),
              size: 20.sp,
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

  Widget _buildTransactionsList(List<PartnerTransaction> transactions) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) => _buildTransactionCard(transactions[index]),
    );
  }

  Widget _buildTransactionCard(PartnerTransaction transaction) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Container(
                          //   padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          //   decoration: BoxDecoration(
                          //     color: _getTypeColor().withValues(alpha: 0.1),
                          //     borderRadius: BorderRadius.circular(4.r),
                          //   ),
                          //   child: Text(
                          //     transaction.currencyTypeName,
                          //     style: TextStyle(
                          //       fontSize: 10.sp,
                          //       fontWeight: FontWeight.w600,
                          //       color: _getTypeColor(),
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(width: 6.w),
                          Text(
                            _formatDate(transaction.createdAt),
                            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          transaction.description!,
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatCurrency(transaction.amount),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: _getTypeColor(),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      transaction.currencyTypeName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor().withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (transaction.returnDate != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event, size: 12.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 4.w),
                    Text(
                      'Qaytarish: ${_formatDate(transaction.returnDate??'')}',
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
            if (transaction.files.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 14.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 4.w),
                  Text(
                    '${transaction.files.length} ta fayl',
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // Header shimmer
        Container(
          margin: EdgeInsets.all(16.w),
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
        ),
        // Transactions shimmer
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            itemCount: 8,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: const Color(0xFFE2E8F0),
              highlightColor: const Color(0xFFF8FAFC),
              child: Container(
                padding: EdgeInsets.all(12.w),
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            height: 10.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 60.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}