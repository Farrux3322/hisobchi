import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

import '../../../components/basic_widgets.dart';

class ReportClientMainPage extends StatefulWidget {
  const ReportClientMainPage({super.key});

  @override
  State<ReportClientMainPage> createState() => _ReportClientMainPageState();
}

class _ReportClientMainPageState extends State<ReportClientMainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - API dan kelgan ma'lumotlar
  final Map<String, dynamic> mockData = {
    "status": true,
    "result": {
      "UZS": {
        "debt": 45000000,
        "credit": 12500000,
        "balance": 32500000,
        "partners_count": 24,
        "operations": {"count": 156, "type": "oparation"},
        "xaqdorlar": {"count": 8, "type": "xaqdor"},
        "qarzdorlar": {"count": 16, "type": "qarzdor"},
        "qarz_expired": {"count": 3, "type": "qarz_expired"},
        "qarz_3_days": {"count": 5, "type": "qarz_3_days"},
        "qarz_7_days": {"count": 8, "type": "qarz_7_days"},
      },
      "USD": {
        "debt": 3500,
        "credit": 1200,
        "balance": 2300,
        "partners_count": 18,
        "operations": {"count": 89, "type": "oparation"},
        "xaqdorlar": {"count": 5, "type": "xaqdor"},
        "qarzdorlar": {"count": 13, "type": "qarzdor"},
        "qarz_expired": {"count": 2, "type": "qarz_expired"},
        "qarz_3_days": {"count": 4, "type": "qarz_3_days"},
        "qarz_7_days": {"count": 7, "type": "qarz_7_days"},
      },
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Hamkorlar xisoboti', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(color: AppTheme.colors.primary, borderRadius: BorderRadius.circular(12)),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'UZS Hisob'),
                    Tab(text: 'USD Hisob'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildReportContent('UZS'), _buildReportContent('USD')]),
    );
  }

  Widget _buildReportContent(String currency) {
    final data = mockData['result'][currency] as Map<String, dynamic>;
    final bool isUZS = currency == 'UZS';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Jami kirim va chiqim - Row
        Row(
          children: [
            Expanded(
              child: _buildMainStatCard(
                title: 'Jami kirim',
                value: _formatCurrency(data['credit'], isUZS),
                icon: AppIcons.income,
                iconColor: Colors.white,
                backgroundColor: const Color(0xFF4CAF50),
                isUZS: isUZS,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMainStatCard(
                title: 'Jami chiqim',
                value: _formatCurrency(data['debt'], isUZS),
                icon: AppIcons.chiqim,
                iconColor: Colors.white,
                backgroundColor: const Color(0xFFEF5350),
                isUZS: isUZS,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Qoldiq va Hamkorlar soni - Row
        Row(
          children: [
            Expanded(
              child: _buildMainStatCard(
                title: 'Qoldiq',
                value: _formatCurrency(data['balance'], isUZS),
                icon: AppIcons.balance,
                iconColor: Colors.white,
                backgroundColor: const Color(0xFF2196F3),
                isUZS: isUZS,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMainStatCard(
                title: 'Hamkorlar',
                value: '${data['partners_count']}',
                icon: AppIcons.clients,
                iconColor: Colors.white,
                backgroundColor: const Color(0xFF9C27B0),
                isUZS: isUZS,
                showCurrency: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Jami operatsiyalar, qarzdorlar, haqdorlar - Row (kichikroq)
        Row(
          children: [
            Expanded(
              child: _buildSmallStatCard(title: 'Operatsiyalar', count: data['operations']['count'], icon: Icons.sync_alt, color: const Color(0xFFFF9800)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSmallStatCard(title: 'Qarzdorlar', count: data['qarzdorlar']['count'], icon: Icons.arrow_upward, color: const Color(0xFFFF5722)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSmallStatCard(title: 'Haqdorlar', count: data['xaqdorlar']['count'], icon: Icons.arrow_downward, color: const Color(0xFF009688)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Qarz muddatlari xisoboti title
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.access_time, color: Colors.amber.shade900, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Qarz muddatlari xisoboti',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
            ],
          ),
        ),

        // Qarz muddatlari - Row (uchta ham)
        Row(
          children: [
            Expanded(
              child: _buildDeadlineCard(subtitle: '', title: "Muddati o'tgan", count: data['qarz_expired']['count'], icon: Icons.error_outline, color: const Color(0xFFD32F2F)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDeadlineCard(title: 'Juda yaqin', subtitle: '(3 kun)', count: data['qarz_3_days']['count'], icon: Icons.warning_amber_sharp, color: const Color(0xFFFF9800)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDeadlineCard(title: 'Yaqinlashmoqda', subtitle: '(7 kun)', count: data['qarz_7_days']['count'], icon: Icons.schedule, color: const Color(0xFFFFA726)),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Asosiy katta statistika kartlari
  Widget _buildMainStatCard({
    required String title,
    required String value,
    required String icon,
    required Color iconColor,
    required Color backgroundColor,
    bool isUZS = true,
    bool showCurrency = true,
  }) {
    return Container(
      height: 110.h,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: backgroundColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: SvgPicture.asset(icon, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn), width: 24, height: 24),
              ),
              Gap(10.w),
              Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: iconColor.withValues(alpha: 0.9)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: iconColor, letterSpacing: 0.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showCurrency) ...[
                const SizedBox(height: 2),
                Text(
                  _getCurrency(isUZS),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: iconColor.withValues(alpha: 0.8)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Kichik statistika kartlari (operatsiyalar, qarzdorlar, haqdorlar uchun)
  Widget _buildSmallStatCard({required String title, required int count, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700], height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),
          // Count
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .1)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color, height: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Qarz muddatlari kartlari - Minimalist Design
  Widget _buildDeadlineCard({required String title, String? subtitle, required int count, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700], height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Icon and Count Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, height: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic value, bool isUZS) {
    if (value == null) return '0';

    final number = value is int ? value : int.tryParse(value.toString()) ?? 0;

    // Faqat raqamni formatlash
    final formatted = number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
    return formatted;
  }

  String _getCurrency(bool isUZS) {
    return isUZS ? 'UZS' : 'USD';
  }
}
