import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NearMeColors {
  // ── NearMe Pitch Deck Palette ──────────────────────────
  static const navyDeep    = Color(0xFF0A0E27); // Full-bleed dark navy background
  static const navyCard    = Color(0xFF12183A); // Cards, inputs, nav bar
  static const navyMid     = Color(0xFF1A2150); // Section containers
  static const navyBorder  = Color(0xFF2A3470); // Subtle borders

  static const gold        = Color(0xFFD4A017); // Primary accent — CTAs, active states
  static const goldLight   = Color(0xFFF5C842); // Gradient highlight
  static const goldGlow    = Color(0x33D4A017); // Gold glow with opacity

  static const electricBlue  = Color(0xFF3B82F6); // Map markers, secondary chips
  static const electricGlow  = Color(0x333B82F6); // Blue glow

  static const textPrimary   = Color(0xFFF0F4FF); // Main text
  static const textSecondary = Color(0xFF8A9BC0); // Subtitles / muted
  static const textMuted     = Color(0xFF4A5680); // Placeholder text

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [navyDeep, navyMid],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class ThemeConfig {
  static ThemeData get darkTheme {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary:          NearMeColors.gold,
      onPrimary:        Colors.black,
      primaryContainer: NearMeColors.navyMid,
      onPrimaryContainer: NearMeColors.gold,
      secondary:        NearMeColors.electricBlue,
      onSecondary:      Colors.white,
      secondaryContainer: Color(0xFF1E3A5F),
      onSecondaryContainer: Colors.white,
      surface:          NearMeColors.navyCard,
      onSurface:        NearMeColors.textPrimary,
      error:            NearMeColors.error,
      onError:          Colors.white,
      outline:          NearMeColors.navyBorder,
      outlineVariant:   NearMeColors.navyMid,
      surfaceTint:      NearMeColors.navyMid,
      inverseSurface:   NearMeColors.textPrimary,
      onInverseSurface: NearMeColors.navyDeep,
      scrim:            Colors.black54,
      shadow:           Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: NearMeColors.navyDeep,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge:  GoogleFonts.inter(color: NearMeColors.textPrimary, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.inter(color: NearMeColors.textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.inter(color: NearMeColors.textPrimary, fontWeight: FontWeight.w700),
        headlineMedium:GoogleFonts.inter(color: NearMeColors.textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.inter(color: NearMeColors.textPrimary, fontWeight: FontWeight.w600),
        titleLarge:    GoogleFonts.inter(color: NearMeColors.textPrimary, fontWeight: FontWeight.w600),
        titleMedium:   GoogleFonts.inter(color: NearMeColors.textPrimary, fontWeight: FontWeight.w500),
        bodyLarge:     GoogleFonts.inter(color: NearMeColors.textPrimary),
        bodyMedium:    GoogleFonts.inter(color: NearMeColors.textSecondary),
        bodySmall:     GoogleFonts.inter(color: NearMeColors.textMuted),
        labelLarge:    GoogleFonts.inter(color: NearMeColors.textPrimary, fontWeight: FontWeight.w600),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: NearMeColors.navyDeep,
        foregroundColor: NearMeColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: NearMeColors.textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: NearMeColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: NearMeColors.navyCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: NearMeColors.navyBorder, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NearMeColors.navyCard,
        hintStyle: GoogleFonts.inter(color: NearMeColors.textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: NearMeColors.textSecondary, fontSize: 14),
        prefixIconColor: NearMeColors.textSecondary,
        suffixIconColor: NearMeColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NearMeColors.navyBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NearMeColors.navyBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NearMeColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NearMeColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NearMeColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: NearMeColors.gold,
          foregroundColor: Colors.black,
          disabledBackgroundColor: NearMeColors.navyBorder,
          disabledForegroundColor: NearMeColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NearMeColors.gold,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NearMeColors.gold,
          side: const BorderSide(color: NearMeColors.gold, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: NearMeColors.gold,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: NearMeColors.navyCard,
        selectedColor: NearMeColors.gold,
        labelStyle: GoogleFonts.inter(color: NearMeColors.textSecondary, fontSize: 12),
        side: const BorderSide(color: NearMeColors.navyBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      dividerTheme: const DividerThemeData(
        color: NearMeColors.navyBorder,
        thickness: 1,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: NearMeColors.navyDeep,
        selectedItemColor: NearMeColors.gold,
        unselectedItemColor: NearMeColors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: NearMeColors.navyCard,
        contentTextStyle: GoogleFonts.inter(color: NearMeColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        actionTextColor: NearMeColors.gold,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: NearMeColors.navyCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: NearMeColors.navyBorder),
        ),
        titleTextStyle: GoogleFonts.inter(
          color: NearMeColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: NearMeColors.textSecondary,
          fontSize: 14,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: NearMeColors.gold,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return NearMeColors.gold;
          return NearMeColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return NearMeColors.goldGlow;
          return NearMeColors.navyBorder;
        }),
      ),

      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: NearMeColors.textPrimary,
        iconColor: NearMeColors.textSecondary,
      ),
    );
  }

  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: NearMeColors.gold,
      brightness: Brightness.light,
    ).copyWith(
      primary: NearMeColors.gold,
      onPrimary: Colors.black,
      secondary: NearMeColors.electricBlue,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF111827),
      outline: const Color(0xFFD8DEE9),
      error: NearMeColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineMedium: GoogleFonts.inter(color: const Color(0xFF111827), fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.inter(color: const Color(0xFF111827), fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.inter(color: const Color(0xFF111827), fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: const Color(0xFF111827)),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF4B5563)),
        bodySmall: GoogleFonts.inter(color: const Color(0xFF6B7280)),
        labelLarge: GoogleFonts.inter(color: const Color(0xFF111827), fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        foregroundColor: const Color(0xFF111827),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: cs.outline, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14),
        labelStyle: GoogleFonts.inter(color: const Color(0xFF4B5563), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NearMeColors.gold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: NearMeColors.gold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: NearMeColors.gold,
        unselectedItemColor: Color(0xFF6B7280),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
