import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';

Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
  if (Platform.isIOS) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Rasmni o'chirish"),
          content: const Text("Siz rostan ham ushbu rasmni o'chirmoqchimisiz?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              isDefaultAction: true,
              child:  Text("Bekor qilish",style: TextStyle(color: Colors.black54,fontSize: 14.sp),),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              isDestructiveAction: true,
              child:  Text("O'chirish"),
            ),
          ],
        );
      },
    );
  } else {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rasmni o'chirish"),
          content: const Text("Siz rostan ham ushbu rasmni o'chirmoqchimisiz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Bekor qilish",style: TextStyle(color: Colors.black54),),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "O'chirish",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}