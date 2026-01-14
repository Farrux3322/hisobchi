import 'package:flutter/material.dart';
import 'package:hisobchi/infrastructure/dto/models/currency/currency_model.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

class AddClientDialogs {
  /// Show currency selection bottom sheet
  static Future<void> showCurrencySelection({
    required BuildContext context,
    required List<Result> currencies,
    Result? selectedCurrency,
    required Function(Result) onSelected,
  }) async {
    final filteredCurrencies = currencies.where((c) => c.deletedAt == null).toList();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header with handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
                ),
              ),

              // Title and close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.colors.primary.withValues(alpha: 0.1),
                            AppTheme.colors.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.currency_exchange_rounded, color: AppTheme.colors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valyuta tanlash',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                          SizedBox(height: 2),
                          Text('Asosiy valyutani tanlang', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredCurrencies.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredCurrencies.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, indent: 72, color: Color(0xFFE2E8F0)),
                        itemBuilder: (context, index) {
                          final currency = filteredCurrencies[index];
                          final isSelected = selectedCurrency?.id == currency.id;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                onSelected(currency);
                                Navigator.pop(bottomSheetContext);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currency.name ?? '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? AppTheme.colors.primary : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(color: AppTheme.colors.primary, shape: BoxShape.circle),
                                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                      )
                                    else
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Valyuta topilmadi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          const Text('Boshqa nom bilan qidiring', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  /// Show validation errors dialog
  static void showValidationErrorDialog(BuildContext context, Map<String, String> errors) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ma\'lumotlarni tekshiring',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                if (errors.length > 1)
                  Text('${errors.length} ta xatolik topildi', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: errors.entries.map((entry) {
                          final isLast = entry.key == errors.entries.last.key;
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF991B1B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        entry.value,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D), height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Tushundim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show general error dialog
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                  child: Icon(icon, color: const Color(0xFFEF4444), size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Yopish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
