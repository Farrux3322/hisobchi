import 'package:flutter/material.dart';

class DisableWidget extends StatelessWidget {
  const DisableWidget({super.key, required this.child, required this.opacity, required this.absorbing});

  final Widget child;
  final double opacity;
  final bool absorbing;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
        absorbing: absorbing,
        child: Opacity(
          opacity: opacity,
          child: child,
        ));
  }
}
