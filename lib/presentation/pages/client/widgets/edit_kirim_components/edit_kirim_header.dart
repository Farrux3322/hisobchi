import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

class EditKirimHeader extends StatelessWidget {
  final bool isKirim;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const EditKirimHeader({
    super.key,
    required this.isKirim,
    required this.isEditing,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 62,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isKirim ? 'Kirim ma\'lumotlari' : 'Chiqim ma\'lumotlari',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggleEdit,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.colors.primary, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEditing ? Icons.close_rounded : Icons.edit,
                        size: 18,
                        color: AppTheme.colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isEditing ? 'Bekor qilish' : 'Tahrirlash',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
