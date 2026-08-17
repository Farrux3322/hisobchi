import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/application/theme/theme_bloc.dart';
import 'package:ehisob/application/theme/theme_event.dart';
import 'package:ehisob/application/theme/theme_state.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';

class ThemeSelectorBottomSheet extends StatelessWidget {
  const ThemeSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.colors.gray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Mavzuni tanlang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Light mode option
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (blocContext, state) {
                  return _buildThemeOption(
                    context: context,
                    icon: Icons.light_mode,
                    title: 'Yorqin',
                    subtitle: 'Kunduzgi mavzu',
                    iconColor: const Color(0xFFFFA500),
                    isSelected: state.isLightMode,
                    onTap: () {
                      blocContext.read<ThemeBloc>().add(
                            const ChangeThemeEvent(ThemeMode.light),
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 12),

              // Dark mode option
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (blocContext, state) {
                  return _buildThemeOption(
                    context: context,
                    icon: Icons.dark_mode,
                    title: 'Qorong\'i',
                    subtitle: 'Tungi mavzu',
                    iconColor: const Color(0xFF5B4FFF),
                    isSelected: state.isDarkMode,
                    onTap: () {
                      blocContext.read<ThemeBloc>().add(
                            const ChangeThemeEvent(ThemeMode.dark),
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppTheme.colors.primary : AppTheme.colors.divider,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.colors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.colors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}