import 'package:flutter/material.dart';

enum InfoBoxType { info, success, warning }

class PSInfoBox extends StatelessWidget {
  final InfoBoxType type;
  final String title;
  final String description;

  const PSInfoBox({
    super.key,
    required this.type,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIcon(),
            color: colors.icon,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.text.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _InfoBoxColors _getColors() {
    switch (type) {
      case InfoBoxType.info:
        return _InfoBoxColors(
          background: const Color(0xFF006FE5).withOpacity(0.1),
          border: const Color(0xFF006FE5).withOpacity(0.2),
          icon: const Color(0xFF006FE5),
          text: const Color(0xFF006FE5),
        );
      case InfoBoxType.success:
        return _InfoBoxColors(
          background: const Color(0xFF00D856).withOpacity(0.1),
          border: const Color(0xFF00D856).withOpacity(0.2),
          icon: const Color(0xFF00D856),
          text: const Color(0xFF00A844),
        );
      case InfoBoxType.warning:
        return _InfoBoxColors(
          background: const Color(0xFFFF9500).withOpacity(0.1),
          border: const Color(0xFFFF9500).withOpacity(0.2),
          icon: const Color(0xFFFF9500),
          text: const Color(0xFFCC7700),
        );
    }
  }

  IconData _getIcon() {
    switch (type) {
      case InfoBoxType.info:
        return Icons.info_outline;
      case InfoBoxType.success:
        return Icons.check_circle_outline;
      case InfoBoxType.warning:
        return Icons.warning_amber_outlined;
    }
  }
}

class _InfoBoxColors {
  final Color background;
  final Color border;
  final Color icon;
  final Color text;

  const _InfoBoxColors({
    required this.background,
    required this.border,
    required this.icon,
    required this.text,
  });
}
