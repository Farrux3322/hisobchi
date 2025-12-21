import 'package:flutter/material.dart';

import '../assets/asset_index.dart';

class SeparatorLine extends StatelessWidget {

  const SeparatorLine({
    super.key,
    this.padding,
    this.color,
  });

  final EdgeInsets? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: ColoredBox(
        color: color ?? AppTheme.colors.divider,
        child: const SizedBox(height: 1, width: double.infinity),
      ),
    );
  }
}
