import 'package:flutter/material.dart';

class PSAdvanceToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggled;

  const PSAdvanceToggle({
    super.key,
    required this.isEnabled,
    required this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggled(!isEnabled),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFFF9500)
                : const Color(0xFFE1E0EE),
            width: isEnabled ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFFFF9500)
                    : const Color(0xFFE1E0EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avans to\'lovi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isEnabled
                          ? const Color(0xFFFF9500)
                          : const Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Dastlabki to\'lov miqdorini belgilash',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
