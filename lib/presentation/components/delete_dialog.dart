import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/assets/theme/app_theme.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Icon(Icons.delete_outline,color: Colors.red,size: 50.r),
      content: Text('Siz rostan ham o\'chirmoqchimisiz?'),
      actions: [
        Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onTap();
              },
              style: ElevatedButton.styleFrom(backgroundColor: CupertinoColors.systemRed, elevation: 0),
              child: Text(
                "Ha, o'chirish",
                style: AppTheme.data.textTheme.titleMedium?.copyWith(color: Color(0xFFFFFFFF), fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
            ),

            Gap(10.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFEEF0F3), elevation: 0),
              child: Text(
                "Yo'q, ortga qaytish",
                style: AppTheme.data.textTheme.titleMedium?.copyWith(color: Color(0xFF444B5A), fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
