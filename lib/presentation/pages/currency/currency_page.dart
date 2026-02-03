import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/currency/exchange_rate_model.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:shimmer/shimmer.dart';

import '../../assets/asset_index.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    // Fetch rates for today by default
    _fetchRatesForDate(selectedDate);
  }

  void _fetchRatesForDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    context.read<CurrencyBloc>().add(GetExchangeRatesByDate(date: formattedDate));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.colors.primary, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchRatesForDate(picked);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshRates() async {
    context.read<CurrencyBloc>().add(const RefreshExchangeRates());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(context),
      body: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: BlocBuilder<CurrencyBloc, CurrencyState>(
          builder: (context, state) {
            return RefreshIndicator(onRefresh: _refreshRates, color: const Color(0xFF6366F1), child: _buildBody(context, state));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: BackArrowButton(),
      title: const Text('Valyuta kurslari'),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey[200], height: 1),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CurrencyState state) {
    if (state.exchangeRatesStatus == Status.loading && state.exchangeRateModel == null) {
      return _buildLoadingState();
    }

    if (state.exchangeRatesStatus == Status.error && state.exchangeRateModel == null) {
      return _buildErrorState(context, state.errorMessage ?? 'Xatolik yuz berdi');
    }

    if (state.exchangeRateModel == null || state.exchangeRateModel!.rates.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCurrencyList(state);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF6366F1), strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Ma\'lumotlar yuklanmoqda...',
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade400),
            ),
            const SizedBox(height: 24),
            const Text(
              'Xatolik yuz berdi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<CurrencyBloc>().add(const GetExchangeRates());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Qayta urinish',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.currency_exchange_rounded, size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ma\'lumot topilmadi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'Hozircha valyuta kurslari mavjud emas',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyList(CurrencyState state) {
    final rates = state.exchangeRateModel!.rates;
    final isLoading = state.exchangeRatesStatus == Status.loading;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Date filter button
        SliverToBoxAdapter(child: _buildDateFilter()),

        // Currency rates list or shimmer
        if (isLoading)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildShimmerCard(), childCount: 8)),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final rate = rates[index];
                return _CurrencyRateCard(rate: rate, index: index, animationController: _animationController);
              }, childCount: rates.length),
            ),
          ),

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildDateFilter() {
    final isToday = selectedDate.year == DateTime.now().year && selectedDate.month == DateTime.now().month && selectedDate.day == DateTime.now().day;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              gradient: LinearGradient(
                colors: [const Color(0xFF6366F1).withValues(alpha: 0.03), const Color(0xFF8B5CF6).withValues(alpha: 0.03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Calendar icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF6366F1), size: 20),
                ),
                const SizedBox(width: 16),

                // Date info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? 'Bugungi kurs' : 'Tanlangan sana',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM yyyy', 'uz').format(selectedDate),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF6366F1), size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(width: 16),

            // Text shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 60,
                      height: 18,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              ),
            ),

            // Rate shimmer
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Currency Rate Card Widget
class _CurrencyRateCard extends StatelessWidget {
  final CurrencyRate rate;
  final int index;
  final AnimationController animationController;

  const _CurrencyRateCard({required this.rate, required this.index, required this.animationController});

  Color _getCurrencyColor(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return const Color(0xFF10B981);
      case 'EUR':
        return const Color(0xFF6366F1);
      case 'RUB':
        return const Color(0xFFEF4444);
      case 'GBP':
        return const Color(0xFF8B5CF6);
      case 'CNY':
        return const Color(0xFFF59E0B);
      case 'KZT':
        return const Color(0xFF06B6D4);
      case 'KGS':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCurrencyIcon(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return Icons.attach_money_rounded;
      case 'EUR':
        return Icons.euro_rounded;
      case 'RUB':
        return Icons.currency_ruble_rounded;
      case 'GBP':
        return Icons.currency_pound_rounded;
      case 'CNY':
        return Icons.currency_yuan_rounded;
      default:
        return Icons.currency_exchange_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCurrencyColor(rate.code);
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval((index * 0.1).clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
      ),
    );

    animationController.forward();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Optional: Show detailed information
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Currency icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: Icon(_getCurrencyIcon(rate.code), color: color, size: 28),
                  ),
                  const SizedBox(width: 16),

                  // Currency info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              rate.code,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                            ),
                            // const SizedBox(width: 8),
                            // Container(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 8,
                            //     vertical: 3,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: color.withOpacity(0.1),
                            //     borderRadius: BorderRadius.circular(6),
                            //   ),
                            //   child: Text(
                            //     rate.nominal,
                            //     style: TextStyle(
                            //       fontSize: 11,
                            //       fontWeight: FontWeight.w600,
                            //       color: color,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rate.nameUz,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  // Rate and diff
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            rate.formattedRate,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                          ),
                          Text(
                            ' UZS',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: rate.isIncreasing
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : rate.isDecreasing
                              ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              rate.isIncreasing
                                  ? Icons.trending_up_rounded
                                  : rate.isDecreasing
                                  ? Icons.trending_down_rounded
                                  : Icons.trending_flat_rounded,
                              size: 14,
                              color: rate.isIncreasing
                                  ? const Color(0xFF10B981)
                                  : rate.isDecreasing
                                  ? const Color(0xFFEF4444)
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rate.formattedDiff,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: rate.isIncreasing
                                    ? const Color(0xFF10B981)
                                    : rate.isDecreasing
                                    ? const Color(0xFFEF4444)
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
