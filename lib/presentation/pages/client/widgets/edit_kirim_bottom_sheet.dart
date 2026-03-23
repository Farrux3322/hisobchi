import 'package:flutter/material.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/income_history_model.dart';
import 'package:hisobchi/presentation/components/full_screen_photo.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../assets/asset_index.dart';

class TransactionDetailBottomSheet extends StatelessWidget {
  final Result transaction;
  final String? partnerPhone;
  final ScrollController scrollController;

  const TransactionDetailBottomSheet({super.key, required this.transaction, required this.scrollController, this.partnerPhone});

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
            decoration: BoxDecoration(color: AppTheme.colors.gray.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 12.h),
                  _buildSecondaryInfo(),
                  SizedBox(height: 10.h),
                  _buildMainInfo(),
                  if (transaction.description != null && transaction.description!.isNotEmpty) ...[SizedBox(height: 10.h), _buildDescription()],
                  if (isCancelled && transaction.canselReason != null && transaction.canselReason!.isNotEmpty) ...[SizedBox(height: 10.h), _buildCancelReason()],
                  if (transaction.files != null && transaction.files!.isNotEmpty) ...[SizedBox(height: 10.h), _buildImageGallery(context)],
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
              boxShadow: [BoxShadow(color: brandColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Icon(isKirim ? Icons.south_west_rounded : Icons.north_east_rounded, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKirim ? 'KIRIM' : 'CHIQIM',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: brandColor.withValues(alpha: 0.7), letterSpacing: 1.2),
                ),
                Text(
                  _formatAmount(transaction.summa ?? '0'),
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          if (isCancelled || isDeleted) _buildBadge(isDeleted ? 'O\'chirilgan' : 'Bekor qilingan', isDeleted ? Colors.grey : const Color(0xFFE11D48)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(label: 'Valyuta', value: transaction.currencyTypeName ?? 'UZS', icon: Icons.monetization_on_rounded, color: const Color(0xFF6366F1)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildInfoCard(
            label: 'Sana',
            value: transaction.createdAt?.length == 19 ? transaction.createdAt?.split(' ').first ?? '' : transaction.createdAt ?? '',
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
        _buildLongInfoRow(label: 'Mijoz', value: transaction.partnerName ?? 'Noma\'lum', icon: Icons.person_rounded, color: const Color(0xFF8B5CF6)),
        if (partnerPhone != null && partnerPhone!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildLongInfoRow(
            label: 'Telefon raqami',
            value: _formatPhoneNumber(partnerPhone!),
            icon: Icons.phone_rounded,
            color: const Color(0xFF8B5CF6),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _sendSms(
                    phoneNumber: partnerPhone!,
                    partnerName: transaction.partnerName ?? 'Mijoz',
                    amount: _formatAmount(transaction.summa ?? '0'),
                    currency: transaction.currencyTypeName ?? '',
                    isIncoming: isKirim,
                    returnDate: (transaction.returnDate != null && transaction.returnDate!.isNotEmpty) ? transaction.returnDate : null,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: SvgPicture.asset(AppIcons.sms, width: 18.w, height: 18.w, colorFilter: const ColorFilter.mode(Color(0xFF6366F1), BlendMode.srcIn)),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _makePhoneCall(partnerPhone!),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: SvgPicture.asset(AppIcons.phone, width: 18.w, height: 18.w, colorFilter: const ColorFilter.mode(Color(0xFF10B981), BlendMode.srcIn)),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (transaction.returnDate != null && transaction.returnDate!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildLongInfoRow(label: 'Qaytarish sanasi', value: _formatDate(transaction.returnDate), icon: Icons.history_rounded, color: const Color(0xFF10B981)),
        ],
        if (transaction.activity != null && transaction.activity!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildLongInfoRow(label: 'Yaratuvchi', value: transaction.activity!, icon: Icons.person_outline, color: AppTheme.colors.primary),
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
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            transaction.description!,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF334155), height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelReason() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cancel, size: 14.sp, color: const Color(0xFFE11D48)),
              SizedBox(width: 8.w),
              Text(
                'BEKOR QILISH SABABI',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFFE11D48), letterSpacing: 1),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            transaction.canselReason ?? 'Sabab ko\'rsatilmagan',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9F1239), height: 1.5, fontWeight: FontWeight.w600),
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
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1),
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
                        images: transaction.files!.map((f) => ImageItem(path: f.url ?? '', isNetwork: true)).toList(),
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
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      image: DecorationImage(image: NetworkImage(file.url ?? ''), fit: BoxFit.cover),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 4.w,
                          bottom: 4.w,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
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

  Widget _buildInfoCard({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.sp, color: color.withValues(alpha: 0.5)),
              SizedBox(width: 6.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _buildLongInfoRow({required String label, required String value, required IconData icon, required Color color, Widget? trailing}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, size: 16.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[SizedBox(width: 8.w), trailing],
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
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendSms({
    required String phoneNumber,
    required String partnerName,
    required String amount,
    required String currency,
    required bool isIncoming,
    String? returnDate,
  }) async {
    String message = "";
    final String senderName = UserData.name;
    final String senderPhone = _formatPhoneNumber(UserData.phone);

    if (isIncoming) {
      // 2. To'lov qabul qilinganda
      message = "Hurmatli $partnerName, Sizdan $amount $currency miqdoridagi to‘lov qabul qilindi.\n"
          "Qabul qiluvchi: $senderName\n"
          "Tel: $senderPhone\n"
          "Hamkorlik uchun rahmat\n"
          "Manba: E-Hisob";
    } else {
      final String header = "Hurmatli $partnerName, ";
      final String footer = "\nBeruvchi: $senderName\nTel: $senderPhone\nManba: E-Hisob";

      if (returnDate != null && returnDate.isNotEmpty) {
        final String formattedDate = _formatDate(returnDate);
        DateTime? dueDate;
        try {
          dueDate = DateTime.parse(returnDate);
        } catch (_) {}

        if (dueDate != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
          final difference = dueDay.difference(today).inDays;

          if (difference == 0) {
            // 4. Bugun qaytarish muddati bo'lsa
            message = "${header}Bugun $amount $currency qarzni qaytarish muddati.$footer";
          } else if (difference > 0 && difference <= 3) {
            // 3. Qarz muddati yaqinlashmoqda
            message = "${header}Siz olgan $amount $currency qarz muddati yaqinlashmoqda.\n"
                "Qaytarish sanasi: $formattedDate$footer";
          } else if (difference < 0) {
            // 5. Qarz muddati o'tib ketgan bo'lsa
            message = "${header}$amount $currency qarz muddati o‘tib ketdi.\n"
                "Iltimos, tez orada to‘lovni amalga oshiring.$footer";
          } else {
            // 1. Yangi qarz berilganda (3 kundan ko'p vaqt bo'lsa)
            message = "${header}Sizga $amount $currency qarz berildi.\n"
                "Qaytarish sanasi: $formattedDate$footer";
          }
        } else {
          // Sana parsing xatosi bo'lsa
          message = "${header}Sizga $amount $currency qarz berildi.$footer";
        }
      } else {
        // Qaytarish sanasi yo'q qarz
        message = "${header}Sizga $amount $currency qarz berildi.$footer";
      }
    }

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri launchUri = Uri.parse('sms:$phoneNumber?body=$encodedMessage');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    final clean = phone.replaceAll(RegExp(r'\D'), '');

    if (clean.length == 9) {
      return '+998 (${clean.substring(0, 2)}) ${clean.substring(2, 5)} ${clean.substring(5, 7)} ${clean.substring(7, 9)}';
    } else if (clean.length == 12 && clean.startsWith('998')) {
      return '+998 (${clean.substring(3, 5)}) ${clean.substring(5, 8)} ${clean.substring(8, 10)} ${clean.substring(10, 12)}';
    }
    return phone;
  }
}