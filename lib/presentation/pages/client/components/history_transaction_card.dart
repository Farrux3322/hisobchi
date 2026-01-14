import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/income_history_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';

class HistoryTransactionCard extends StatelessWidget {
  final Result item;
  final VoidCallback onTap;
  final Function(Result) onDelete;
  final Function(Result)? onCancel;
  final Function(Result)? onRestore;
  final Function(Result)? onForceDelete;
  final String timeText;

  const HistoryTransactionCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.onCancel,
    this.onRestore,
    this.onForceDelete,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    final bool isKirim = item.type == 'debt';
    final bool isCanceled = item.isCancelled == 1;
    final bool isDeleted = item.deletedAt != null && item.deletedAt!.isNotEmpty;
    final Color amountColor = isKirim ? Colors.green : Colors.red;
    final Color iconBg = isKirim ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: onTap,
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: isDeleted ? 0.9 : 0.7,
          children: isDeleted
              ? [
                  if (onRestore != null)
                    SlidableAction(
                      onPressed: (context) => onRestore!(item),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.restore,
                      label: "Tiklash",
                      borderRadius: BorderRadius.circular(12),
                    ),
                  if (onForceDelete != null)
                    SlidableAction(
                      onPressed: (context) => onForceDelete!(item),
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_forever,
                      label: "Butunlay o'chirish",
                      borderRadius: BorderRadius.circular(12),
                    ),
                ]
              : [
                  SlidableAction(
                    onPressed: (context) => onDelete(item),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                    label: "O'chirish",
                    borderRadius: BorderRadius.circular(12),
                  ),
                  if (!isCanceled && onCancel != null)
                    SlidableAction(
                      onPressed: (context) => onCancel!(item),
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: Colors.white,
                      icon: Icons.cancel_outlined,
                      label: 'Bekor qilish',
                      borderRadius: BorderRadius.circular(12),
                    ),
                ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: isDeleted ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isDeleted ? Border.all(color: Colors.red.shade300, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: isDeleted ? Colors.red.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: SvgPicture.asset(isKirim ? AppIcons.income : AppIcons.chiqim),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type == 'debt' ? 'Kirim' : 'Chiqim',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(timeText, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              RichText(
                textAlign: TextAlign.end,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: PriceFormatter.priceFormat('${item.summa ?? 0}'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                        decoration: isCanceled ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.red,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: item.currencyTypeName ?? '',
                      style: TextStyle(
                        fontSize: 12, // Reduced font size for currency
                        fontWeight: FontWeight.w600,
                        color: amountColor.withValues(alpha: 0.8),
                        decoration: isCanceled ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
