import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/infrastructure/models/partner_report_model.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/pages/client/report/partner_operations_detail_page.dart';

class DebtReportDetailPage extends StatelessWidget {
  final CurrencyReport data;
  final bool isUZS;

  const DebtReportDetailPage({
    super.key,
    required this.data,
    required this.isUZS,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Qarz muddatlari hisoboti',
          style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: const BackArrowButton(),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDetailCard(
            context: context,
            title: "Muddati o'tgan",
            subtitle: 'To\'lov vaqti o\'tib ketgan qarzlar',
            count: data.qarzExpired.count,
            icon: Icons.error_outline,
            color: const Color(0xFFD32F2F),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartnerOperationsDetailPage(
                    type: 'qarz_expired',
                    currencyTypeId: isUZS ? 1 : 2,
                    title: "Muddati o'tgan qarzlar",
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            context: context,
            title: 'Bugun',
            subtitle: 'Bugungi kunda to\'lanishi kerak bo\'lgan qarzlar',
            count: data.qarz3Days.count,
            icon: Icons.warning_amber_sharp,
            color: const Color(0xFFFF9800),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartnerOperationsDetailPage(
                    type: data.qarz3Days.type,
                    currencyTypeId: isUZS ? 1 : 2,
                    title: 'Bugun qarzlar',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            context: context,
            title: 'Yaqinlashmoqda',
            subtitle: 'Keyingi 3 kun ichida to\'lanishi kerak bo\'lgan qarzlar',
            count: data.qarz7Days.count,
            icon: Icons.schedule,
            color: const Color(0xFFFFA726),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartnerOperationsDetailPage(
                    type: data.qarz7Days.type,
                    currencyTypeId: isUZS ? 1 : 2,
                    title: '3 kun ichida qarzlar',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Text(
                      'mijoz',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
