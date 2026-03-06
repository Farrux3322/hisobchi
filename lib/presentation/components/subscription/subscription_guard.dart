import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi/application/subscription/subscription_status_cubit.dart';
import 'package:hisobchi/domain/common/enums/subscription_status.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/routes/entity/routes.dart';

class SubscriptionGuard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRestricted;
  final bool fallbackToDisable;

  const SubscriptionGuard({super.key, required this.child, this.onRestricted, this.fallbackToDisable = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionStatusCubit, SubscriptionStatus>(
      builder: (context, status) {
        if (status.canCreate) {
          return child;
        }

        if (fallbackToDisable) {
          return Opacity(opacity: 0.5, child: AbsorbPointer(child: child));
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (onRestricted != null) {
              onRestricted!();
            } else {
              _showSubscriptionDialog(context);
            }
          },
          child: AbsorbPointer(child: child),
        );
      },
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.fromLTRB(24.r, 24.r, 24.r, 16.r),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 48.r,
              color: AppTheme.colors.primary,
            ),
            SizedBox(height: 16.r),
            Text(
              'Ushbu amalni bajarish uchun tarifingizni yangilang',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48.r,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.pushNamed(Routes.subscription.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Sotib olish',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
