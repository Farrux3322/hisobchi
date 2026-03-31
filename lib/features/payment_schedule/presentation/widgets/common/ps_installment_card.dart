import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/installment_item_model.dart';

class PSInstallmentCard extends StatelessWidget {
  final InstallmentItemModel item;
  final bool isEditable;
  final ValueChanged<String>? onLabelEdit;
  final ValueChanged<double>? onAmountEdit;
  final ValueChanged<DateTime>? onDateEdit;
  final VoidCallback? onDelete;

  const PSInstallmentCard({
    super.key,
    required this.item,
    this.isEditable = false,
    this.onLabelEdit,
    this.onAmountEdit,
    this.onDateEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isAdvance
              ? const Color(0xFFFF9500)
              : const Color(0xFFE1E0EE),
          width: item.isAdvance ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.isAdvance)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AVANS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF9500),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              if (item.isAdvance) const Spacer(),
              if (isEditable && onLabelEdit != null)
                GestureDetector(
                  onTap: () => _showLabelEditDialog(context),
                  child: Row(
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF202020),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202020),
                  ),
                ),
              if (!item.isAdvance) const Spacer(),
              if (isEditable && onDelete != null && !item.isAdvance)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: const Color(0xFFDE5050),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Summa',
                  value: NumberFormat('#,###').format(item.amount),
                  isEditable: isEditable,
                  onTap: isEditable && onAmountEdit != null
                      ? () => _showAmountEditDialog(context)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  label: 'Sana',
                  value: dateFormat.format(item.dueDate),
                  isEditable: isEditable,
                  onTap: isEditable && onDateEdit != null
                      ? () => _showDatePicker(context)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String value,
    required bool isEditable,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202020),
                    ),
                  ),
                ),
                if (isEditable)
                  const Icon(
                    Icons.edit,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLabelEditDialog(BuildContext context) {
    final controller = TextEditingController(text: item.label);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nomni tahrirlash'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              onLabelEdit?.call(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _showAmountEditDialog(BuildContext context) {
    final controller = TextEditingController(
      text: item.amount.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Summani tahrirlash'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Summa',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              onAmountEdit?.call(amount);
              Navigator.pop(context);
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: item.dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      onDateEdit?.call(date);
    }
  }
}
