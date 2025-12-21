import 'package:flutter/material.dart';

class FadeTransitionX extends StatelessWidget {
  const FadeTransitionX({
    super.key,
    required this.child,
    required this.animation,
  });

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0,
        end: 1,
      ).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.03),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
