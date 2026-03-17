import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hisobchi/infrastructure/models/partner_operations_detail_model.dart';
import 'package:hisobchi/presentation/components/full_screen_photo.dart';
import '../../../../assets/asset_index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';

class PartnerOperationDetailSheet extends StatelessWidget {
  final PartnerOperation operation;

  const PartnerOperationDetailSheet({
    super.key,
    required this.operation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.colors.gray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            _buildDashboardContent(context),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final isIncoming = !operation.isCredit;

    // Premium Curated Palette
    final brandColor = isIncoming ? const Color(0xFF10B981) : const Color(0xFFE11D48); // Emerald-500 vs Rose-600
    final surfaceColor = isIncoming ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2); // Emerald-50 vs Rose-50
    final borderColor = isIncoming ? const Color(0xFFD1FAE5) : const Color(0xFFFECDD3); // Emerald-100 vs Rose-100

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Refined Minimalist Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: brandColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: brandColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isIncoming ? Icons.south_west_rounded : Icons.north_east_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operation.type=='credit' ? 'Qarz':'Kirim',
                        // operation.typeDisplay.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: brandColor.withValues(alpha: 0.6),
                          letterSpacing: 1,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${isIncoming ? '+' : '-'}${_formatMoney(operation.remainingAmount)} ',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: operation.currencyTypeName,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B), // Slate-500
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 18.sp, color: AppTheme.colors.gray),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 2. High-Density Info Grid with Subtle Containers
          Row(
            children: [
              Expanded(
                child: _buildMinimalInfo(
                  label: 'Hamkor',
                  value: operation.partnerName,
                  color: const Color(0xFF6366F1), // Indigo
                  icon: Icons.person_rounded,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMinimalInfo(
                  label: 'Yaratilgan sana',
                  value: _formatDate(operation.createdAt),
                  color: const Color(0xFFF59E0B), // Amber
                  icon: Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),

          // Partner Phone (if available)
          if (operation.partnerPhone != null && operation.partnerPhone!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _buildMinimalInfo(
              label: 'Telefon raqami',
              value: _formatPhoneNumber(operation.partnerPhone!),
              color: const Color(0xFF8B5CF6), // Purple
              icon: Icons.phone_rounded,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _sendSms(
                      phoneNumber: operation.partnerPhone!,
                      partnerName: operation.partnerName,
                      amount: _formatMoney(operation.remainingAmount),
                      currency: operation.currencyTypeName,
                      isIncoming: !operation.isCredit,
                      dueDate: operation.hasDueDate ? operation.dueDate : null,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.sms,
                        width: 18.w,
                        height: 18.w,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF6366F1),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _makePhoneCall(operation.partnerPhone!),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.phone,
                        width: 18.w,
                        height: 18.w,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF10B981),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Due Date and Status Row
          if (operation.hasDueDate || operation.statusDisplay.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                if (operation.hasDueDate)
                  Expanded(
                    child: _buildMinimalInfo(
                      label: operation.isOverdue
                          ? "Muddati o'tgan"
                          : operation.daysLeft != null && operation.daysLeft! <= 3
                              ? 'Yaqinlashmoqda'
                              : 'Qaytarish sanasi',
                      value: _formatDueDate(operation.dueDate!),
                      color: operation.isOverdue
                          ? const Color(0xFFEF4444)
                          : operation.daysLeft != null && operation.daysLeft! <= 3
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                      icon: operation.isOverdue
                          ? Icons.error_outline_rounded
                          : Icons.schedule_rounded,
                      isUrgent: operation.isOverdue,
                    ),
                  ),
                if (operation.hasDueDate && operation.statusDisplay.isNotEmpty)
                  SizedBox(width: 12.w),
                if (operation.statusDisplay.isNotEmpty)
                  Expanded(
                    child: _buildMinimalInfo(
                      label: 'Holati',
                      value: operation.status??'',
                      color: const Color(0xFF10B981),
                      icon: Icons.schedule_rounded,
                      isUrgent: operation.status?.toLowerCase() == 'cancelled',
                    ),
                  ),
              ],
            ),
          ],

          // Overdue/Days Left Info
          if (operation.isOverdue && operation.daysOverdue != null) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2), // Red-50
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFFECDD3)), // Red-100
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notification_important_rounded,
                      size: 16.sp,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      '${operation.daysOverdue} kun muddati o\'tgan',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB91C1C), // Red-700
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (operation.daysLeft != null && operation.daysLeft! > 0) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB), // Amber-50
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFFDE68A)), // Amber-100
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      size: 16.sp,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      operation.daysLeft == 0
                          ? 'Bugun qaytarish muddati'
                          : '${operation.daysLeft} kun qoldi',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309), // Amber-700
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Amount Details (Scheduled, Paid, Remaining)
          if ((operation.scheduledAmount != null && operation.scheduledAmountValue > 0) &&
              (operation.paidAmount != null && operation.paidAmountValue > 0)) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // Slate-50
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)), // Slate-200
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, size: 12.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(width: 6.w),
                      Text(
                        'Summa tafsilotlari',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  if (operation.scheduledAmount != null && operation.scheduledAmountValue > 0) ...[
                    _buildAmountRow(
                      'Rejalashtirilgan:',
                      _formatMoney(operation.scheduledAmount!),
                      operation.currencyTypeName,
                    ),
                    SizedBox(height: 4.h),
                  ],
                  if (operation.paidAmount != null && operation.paidAmountValue > 0) ...[
                    _buildAmountRow(
                      'To\'langan:',
                      _formatMoney(operation.paidAmount!),
                      operation.currencyTypeName,
                      color: const Color(0xFF10B981),
                    ),
                    SizedBox(height: 4.h),
                  ],
                  _buildAmountRow(
                    'Qoldiq:',
                    _formatMoney(operation.remainingAmount),
                    operation.currencyTypeName,
                    color: const Color(0xFF6366F1),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],

          // Description
          if (operation.hasDescription) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // Slate-50
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)), // Slate-200
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 12.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(width: 6.w),
                      Text(
                        'Izoh',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    operation.description!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF334155), // Slate-700
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Files
          if (operation.hasFiles) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // Slate-50
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)), // Slate-200
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_file_rounded, size: 12.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(width: 6.w),
                      Text(
                        'Rasmlar',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: operation.files.map((file) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageViewerPage(
                                images: operation.files.map((f) => ImageItem(path: f.url, isNetwork: true)).toList(),
                                initialIndex: operation.files.indexOf(file),
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: file.url,
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              image: DecorationImage(
                                image: NetworkImage(file.url),
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
                                      color: Colors.black.withValues(alpha: 0.5),
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
            ),
          ],
          SizedBox(height: 12.h),
          _buildMinimalInfo(
            label: 'Yaratuvchi',
            value: operation.activity ?? 'Noma\'lum',
            color: AppTheme.colors.primary,
            icon: Icons.person_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalInfo({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    bool isUrgent = false,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate-100
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 12.sp, color: color.withValues(alpha: 0.5)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54, // Slate-400
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isUrgent ? FontWeight.w800 : FontWeight.w700,
                    color: isUrgent ? color : const Color(0xFF1E293B), // Slate-800
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 8.w),
            trailing,
          ],
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Qo'ng'iroq qilish imkoni yo'q");
    }
  }

  Future<void> _sendSms({
    required String phoneNumber,
    required String partnerName,
    required String amount,
    required String currency,
    required bool isIncoming,
    String? dueDate,
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

      if (dueDate != null && dueDate.isNotEmpty) {
        final String formattedDate = _formatDueDate(dueDate);
        DateTime? dueDateTime;
        try {
          dueDateTime = DateTime.parse(dueDate);
        } catch (_) {
          // Fallback parsing for dd.MM.yyyy
          final parts = dueDate.split('.');
          if (parts.length == 3) {
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final year = int.tryParse(parts[2]);
            if (day != null && month != null && year != null) {
              dueDateTime = DateTime(year, month, day);
            }
          }
        }

        if (dueDateTime != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final dueDay = DateTime(dueDateTime.year, dueDateTime.month, dueDateTime.day);
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
            message = "$header$amount $currency qarz muddati o‘tib ketdi.\n"
                "Iltimos, tez orada to‘lovni amalga oshiring.$footer";
          } else {
            // 1. Yangi qarz berilganda
            message = "${header}Sizga $amount $currency qarz berildi.\n"
                "Qaytarish sanasi: $formattedDate$footer";
          }
        } else {
          // Sana parsing xatosi bo'lsa
          message = "${header}Sizga $amount $currency qarz berildi.$footer";
        }
      } else {
        // Muddat belgilanmagan qarz
        message = "${header}Sizga $amount $currency qarz berildi.$footer";
      }
    }

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri launchUri = Uri.parse('sms:$phoneNumber?body=$encodedMessage');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("SMS yuborish imkoni yo'q");
    }
  }

  Widget _buildAmountRow(String label, String amount, String currency, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: amount,
                style: TextStyle(
                  fontSize: isBold ? 15.sp : 14.sp,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
                  color: color ?? const Color(0xFF334155),
                ),
              ),
              TextSpan(
                text: ' $currency',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMoney(String amount) {
    final value = double.tryParse(amount) ?? 0.0;
    final intValue = value.toInt();
    return intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime? date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
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

      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDueDate(String dateStr) {
    try {
      DateTime? date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
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

      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
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

  // Color _getStatusColor(String? status) {
  //   if (status == null) return const Color(0xFF64748B);
  //   switch (status.toLowerCase()) {
  //     case 'pending':
  //       return const Color(0xFFF59E0B); // Amber
  //     case 'completed':
  //       return const Color(0xFF10B981); // Green
  //     case 'cancelled':
  //       return const Color(0xFFEF4444); // Red
  //     default:
  //       return const Color(0xFF64748B); // Gray
  //   }
  // }
  //
  // IconData _getStatusIcon(String? status) {
  //   if (status == null) return Icons.help_outline_rounded;
  //   switch (status.toLowerCase()) {
  //     case 'pending':
  //       return Icons.schedule_rounded;
  //     case 'completed':
  //       return Icons.check_circle_outline_rounded;
  //     case 'cancelled':
  //       return Icons.cancel_outlined;
  //     default:
  //       return Icons.help_outline_rounded;
  //   }
  // }
}