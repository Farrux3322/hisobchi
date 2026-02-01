import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/subscription/subscription_status_cubit.dart';
import 'package:hisobchi/domain/common/enums/subscription_status.dart';
import 'package:oktoast/oktoast.dart';

class SubscriptionGuard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRestricted;
  final bool fallbackToDisable;

  const SubscriptionGuard({
    super.key,
    required this.child,
    this.onRestricted,
    this.fallbackToDisable = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionStatusCubit, SubscriptionStatus>(
      builder: (context, status) {
        if (status.canCreate) {
          return child;
        }

        if (fallbackToDisable) {
          return Opacity(
            opacity: 0.5,
            child: AbsorbPointer(child: child),
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (onRestricted != null) {
              onRestricted!();
            } else {
              showToast(
                'Ushbu amalni bajarish uchun tarifingizni yangilang',
                position: ToastPosition.bottom,
                backgroundColor: Colors.red,
              );
            }
          },
          child: AbsorbPointer(child: child),
        );
      },
    );
  }
}
