import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

class EditKirimFooter extends StatelessWidget {
  final bool isEditing;
  final bool isKirim;
  final VoidCallback onSubmit;

  const EditKirimFooter({
    super.key,
    required this.isEditing,
    required this.isKirim,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditing) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'O\'zgarishlarni saqlash',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
