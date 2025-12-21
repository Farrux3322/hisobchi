import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hisobchi/infrastructure/dto/models/subscription/pricing_plan_model.dart';
import 'package:hisobchi/presentation/assets/res/app_icons.dart';

class TarifCard extends StatelessWidget {
  final PricingPlanModel tarif;
  final Color color;

  const TarifCard({super.key, required this.tarif, required this.color});

  String _formatValue(int? value) {
    if (value == null) return 'Cheksiz';
    if (value == -1) return 'Cheksiz';
    return '$value ta';
  }

  String _getIcon(String? value) {
    if (value == null) return AppIcons.standart;
    if (value == 'STANDART') return AppIcons.standart;
    if (value == 'BUSINESS') return AppIcons.business;
    if (value == 'PROFESSIONAL') return AppIcons.professional;
    return AppIcons.standart;
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: SvgPicture.asset(_getIcon(tarif.name)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarif.displayName ?? tarif.name ?? '',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                      ),
                      if (tarif.description != null) Text(tarif.description!, style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('Mijozlar soni:', _formatValue(tarif.maxCustomers), color),
            _buildFeatureItem('Loyihalar soni:', _formatValue(tarif.maxProjects), color),
            _buildFeatureItem('SMS / Oy limit:', _formatValue(tarif.smsPerMonth), color),
            if (tarif.features?.reports == true) _buildFeatureItem('Hisobotlar:', 'Cheksiz', color),
            if (tarif.features?.fileUpload == true) _buildFeatureItem('Rasm va fayl yuklash:', 'Cheksiz', color),
            const SizedBox(height: 16),
            DottedLine(dashColor: Color(0xFFEDECF8)),
            const SizedBox(height: 8),
            if (tarif.monthlyPrice != null) _buildPriceSection('Oylik', tarif.monthlyPrice!.formatted, null, null, null,),
            const SizedBox(height: 8),
            DottedLine(dashColor: Color(0xFFEDECF8)),
            if (tarif.semiAnnualPrice != null) ...[
              const SizedBox(height: 16),
              _buildPriceSection(
                '6 oylik',
                tarif.semiAnnualPrice!.formatted,
                tarif.semiAnnualPrice!.discountValue > 0 ? '-${tarif.semiAnnualPrice!.discountValue.toInt()}%' : null,
                tarif.semiAnnualPrice!.description,
                null,
              ),
            ],
            const SizedBox(height: 8),
            DottedLine(dashColor: Color(0xFFEDECF8)),

            if (tarif.annualPrice != null) ...[
              const SizedBox(height: 8),
              _buildPriceSection(
                'Yillik',
                tarif.annualPrice!.formatted,
                tarif.annualPrice!.discountValue > 0 ? '-${tarif.annualPrice!.discountValue.toInt()}%' : null,
                tarif.annualPrice!.description,
                tarif.annualPrice!.description1,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String label, String value, Color planColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SvgPicture.asset(AppIcons.success),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w400),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 15, color: value == 'Cheksiz' ?  color : planColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(String muddat, String? narx, String? chegirma, String? tejash, String? bepul) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          muddat,
          style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              narx??'',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            if (chegirma != null) ...[
              const SizedBox(width: 8),
              Text(
                chegirma,
                style: const TextStyle(fontSize: 18, color: Color(0xFF34C759), fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        if (tejash != null || bepul != null) ...[
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
              children: [
                if (tejash != null && tejash.isNotEmpty)
                  TextSpan(
                    text: tejash,
                    style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                  ),
                if (bepul != null && bepul.isNotEmpty) ...[
                  if (tejash != null && tejash.isNotEmpty) const TextSpan(text: ' '),
                  TextSpan(
                    text: bepul,
                    style: const TextStyle(color: Color(0xFF8E8E93)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
