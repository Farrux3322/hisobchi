import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            val.toString(),
            maxLines: 1,
            style: style,
          ),
        );
      },
    );
  }
}
