import 'package:flutter/material.dart';

class PSSectionCard extends StatelessWidget {
  final String? label;
  final Widget child;
  final bool highlighted;
  final Color? highlightColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const PSSectionCard({
    super.key,
    this.label,
    required this.child,
    this.highlighted = false,
    this.highlightColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: highlighted
                      ? (highlightColor ?? const Color(0xFF006FE5))
                      : const Color(0xFFE1E0EE),
                  width: highlighted ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
