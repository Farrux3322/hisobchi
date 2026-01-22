import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/income_history_model.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/full_screen_photo.dart';
import 'package:intl/intl.dart';

class TransactionDetailBottomSheet extends StatelessWidget {
  final Result transaction;
  final ScrollController scrollController;

  const TransactionDetailBottomSheet({
    super.key,
    required this.transaction,
    required this.scrollController,
  });

  bool get isKirim => transaction.type == 'debt';
  bool get isCancelled => transaction.isCancelled == 1;
  bool get isDeleted => transaction.deletedAt != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.colors.gray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 24.h),
                  _buildMainInfo(),
                  SizedBox(height: 20.h),
                  _buildSecondaryInfo(),
                  if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    _buildDescription(),
                  ],
                  if (transaction.files != null && transaction.files!.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    _buildImageGallery(context),
                  ],
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final brandColor = isKirim ? const Color(0xFF10B981) : const Color(0xFFE11D48);
    final surfaceColor = isKirim ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2);
    final borderColor = isKirim ? const Color(0xFFD1FAE5) : const Color(0xFFFECDD3);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: brandColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: brandColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isKirim ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKirim ? 'KIRIM' : 'CHIQIM',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: brandColor.withOpacity(0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  _formatAmount(transaction.summa ?? '0'),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (isCancelled || isDeleted)
            _buildBadge(
              isDeleted ? 'O\'chirilgan' : 'Bekor qilingan',
              isDeleted ? Colors.grey : const Color(0xFFE11D48),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            label: 'Valyuta',
            value: transaction.currencyTypeName ?? 'UZS',
            icon: Icons.monetization_on_rounded,
            color: const Color(0xFF6366F1),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildInfoCard(
            label: 'Sana',
            value: _formatDate(transaction.createdAt),
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryInfo() {
    return Column(
      children: [
        _buildLongInfoRow(
          label: 'Hamkor',
          value: transaction.partnerName ?? 'Noma\'lum',
          icon: Icons.person_rounded,
          color: const Color(0xFF8B5CF6),
        ),
        if (transaction.returnDate != null && transaction.returnDate!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildLongInfoRow(
            label: 'Qaytarish sanasi',
            value: _formatDate(transaction.returnDate),
            icon: Icons.history_rounded,
            color: const Color(0xFF10B981),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 14.sp, color: const Color(0xFF94A3B8)),
              SizedBox(width: 8.w),
              Text(
                'IZOH',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            transaction.description!,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF334155),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_rounded, size: 14.sp, color: const Color(0xFF94A3B8)),
              SizedBox(width: 8.w),
              Text(
                'RASMLAR',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: transaction.files!.map((file) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageViewerPage(
                        images: transaction.files!
                            .map((f) => ImageItem(path: f.url ?? '', isNetwork: true))
                            .toList(),
                        initialIndex: transaction.files!.indexOf(file),
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: file.url ?? '',
                  child: Container(
                    width: 76.w,
                    height: 76.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(file.url ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 4.w,
                          bottom: 4.w,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.fullscreen_rounded, size: 12.sp, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.sp, color: color.withOpacity(0.5)),
              SizedBox(width: 6.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(String value) {
    if (value.isEmpty) return '0';
    final double? amount = double.tryParse(value);
    if (amount == null) return value;
    
    final formatter = NumberFormat('#,###', 'uz-UZ');
    return formatter.format(amount).replaceAll(',', ' ');
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Noma\'lum';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (_) {
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('dd.MM.yyyy').format(date);
      } catch (_) {
        return dateStr;
      }
    }
  }
}
