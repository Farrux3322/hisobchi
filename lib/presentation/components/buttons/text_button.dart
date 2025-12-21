import 'package:flutter/material.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

class TextButtonX extends StatelessWidget {
  const TextButtonX({
    super.key,
    required this.onPressed,
    required this.text,
    this.withUnderLine = true,
    this.style,
  });

  final VoidCallback onPressed;
  final String text;
  final bool withUnderLine;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = AppTheme.data.textTheme.bodyLarge?.copyWith(color: AppTheme.colors.primary);

    if (withUnderLine) {
      textStyle = AppTheme.data.textTheme.bodyLarge?.copyWith(
        shadows: [Shadow(color: AppTheme.colors.primary, offset: const Offset(0, -5))],
        color: Colors.transparent,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.colors.primary,
        decorationThickness: 2,
      );
    }
    return InkWell(
      onTap: onPressed,
      child: Text(
        text,
        style: style ?? textStyle,
      ),
    );
  }
}
