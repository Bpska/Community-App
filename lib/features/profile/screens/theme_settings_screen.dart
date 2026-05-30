import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/config/theme_config.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preview card
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [NearMeColors.navyCard, NearMeColors.navyMid]
                    : [Colors.white, const Color(0xFFF0F4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? NearMeColors.navyBorder : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NearMeColors.gold.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.palette_rounded,
                          color: NearMeColors.gold, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current: ${themeService.selectedTheme}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark
                                ? NearMeColors.textPrimary
                                : const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          'Choose a theme below',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? NearMeColors.textSecondary
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Theme options
          Text(
            'APPEARANCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? NearMeColors.textMuted : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),

          _ThemeOption(
            icon: Icons.light_mode_rounded,
            title: 'Light Mode',
            subtitle: 'Clean and bright interface',
            value: 'Light',
            selectedValue: themeService.selectedTheme,
            accentColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 10),
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'Easy on the eyes at night',
            value: 'Dark',
            selectedValue: themeService.selectedTheme,
            accentColor: NearMeColors.electricBlue,
          ),
          const SizedBox(height: 10),
          _ThemeOption(
            icon: Icons.brightness_auto_rounded,
            title: 'System Default',
            subtitle: 'Follows your device settings',
            value: 'System Default',
            selectedValue: themeService.selectedTheme,
            accentColor: NearMeColors.success,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String selectedValue;
  final Color accentColor;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selectedValue,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.read<ThemeService>().setTheme(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withAlpha(isDark ? 20 : 15)
              : (isDark ? NearMeColors.navyCard : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor.withAlpha(isDark ? 120 : 180)
                : (isDark ? NearMeColors.navyBorder : Colors.grey.shade200),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withAlpha(isDark ? 30 : 20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withAlpha(isDark ? 40 : 30)
                    : (isDark
                        ? NearMeColors.navyMid
                        : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? accentColor
                    : (isDark
                        ? NearMeColors.textSecondary
                        : Colors.grey[600]),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                      color: isSelected
                          ? accentColor
                          : (isDark
                              ? NearMeColors.textPrimary
                              : const Color(0xFF111827)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? NearMeColors.textSecondary
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? accentColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : (isDark
                          ? NearMeColors.navyBorder
                          : Colors.grey.shade300),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
