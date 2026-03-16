import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:hisobchi/infrastructure/dto/models/subscription/pricing_plan_model.dart';
class TarifCard extends StatelessWidget {
  final PricingPlanModel tarif;

  const TarifCard({super.key, required this.tarif});

  String _formatValue(int? value) {
    if (value == null) return 'Cheksiz';
    if (value == -1) return 'Cheksiz';
    return '$value ta';
  }

  IconData _getIconData(String? value) {
    if (value == 'BUSINESS') return Icons.business_center_rounded;
    if (value == 'PROFESSIONAL') return Icons.workspace_premium_rounded;
    return Icons.rocket_launch_rounded;
  }



  LinearGradient _getGradient(String? name) {
    if (name == 'BUSINESS') {
      return const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFDB2777)], // Royal Purple to Fuchsia
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name == 'PROFESSIONAL') {
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFFF6B35)], // Amber → Warm Orange

        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)], // Vibrant Indigo to Blue
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient(tarif.name);
    final isBusiness = tarif.name == 'PROFESSIONAL';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Sophisticated Mesh Patterns
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.0)],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.0)],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        _getIconData(tarif.name),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tarif.displayName ?? tarif.name ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                          ),
                          if (tarif.description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                tarif.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFeatureItem('Hamkorlar:', _formatValue(tarif.maxCustomers)),
                _buildFeatureItem('Loyihalar:', _formatValue(tarif.maxProjects)),
                _buildFeatureItem('Xodimlar soni:', _formatValue(tarif.maxUsers)),
                _buildFeatureItem('SMS Limit (har oyda):', _formatValue(tarif.smsPerMonth)),
                if (tarif.features?.reports == true) _buildFeatureItem('Hisobotlar:', 'Cheksiz'),
                if (tarif.features?.fileUpload == true) _buildFeatureItem('Fayl yuklash:', 'Cheksiz'),
                const SizedBox(height: 12),
                DottedLine(dashColor: Colors.white.withValues(alpha: 0.2), dashLength: 4, dashGapLength: 4),
                const SizedBox(height: 16),
                if (tarif.monthlyPrice != null) _buildPriceSection('Oylik', tarif.monthlyPrice!.formatted, null, null, null),
                if (tarif.semiAnnualPrice != null) ...[
                  const SizedBox(height: 12),
                  _buildPriceSection(
                    '6 oylik',
                    tarif.semiAnnualPrice!.formatted,
                    tarif.semiAnnualPrice!.discountValue > 0 ? '-${tarif.semiAnnualPrice!.discountValue.toInt()}%' : null,
                    tarif.semiAnnualPrice!.description,
                    null,
                  ),
                ],
                if (tarif.annualPrice != null) ...[
                  const SizedBox(height: 12),
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
          if (isBusiness)
            Positioned(
              top: 16,
              right: -35,
              child: Transform.rotate(
                angle: 0.785398, // 45 degrees
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'TAVSIYA',
                      style: TextStyle(
                        color: gradient.colors.first,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(String muddat, String? narx, String? chegirma, String? tejash, String? bepul) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              muddat.toUpperCase(),
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            if (chegirma != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  chegirma,
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          narx ?? '',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        if (tejash != null || bepul != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              if (tejash != null && tejash.isNotEmpty)
                Text(
                  tejash,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              if (bepul != null && bepul.isNotEmpty) ...[
                if (tejash != null && tejash.isNotEmpty) const SizedBox(width: 8),
                Text(
                  bepul,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

}
