import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ── Color Scheme ──
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        secondary: AppColors.secondary,
        onSecondary: AppColors.surface,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        outline: AppColors.textSecondary,
        outlineVariant: AppColors.textSecondary,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // ── Typography ──
      textTheme: GoogleFonts.poppinsTextTheme(_buildTextTheme()),
      primaryTextTheme: GoogleFonts.poppinsTextTheme(_buildTextTheme()),

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      // ── Filled Button ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.surface,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      // ── Outlined Button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
      ),

      // ── Card Theme ──
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── FAB ──
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.surface,
        elevation: 8,
      ),

      // ── Navigation Bar ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 12,
        indicatorColor: AppColors.accent.withValues(alpha: 0.08),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          );
        }),
      ),

      // ── Chip Theme ──
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.divider,
        selectedColor: AppColors.accent.withValues(alpha: 0.12),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: AppColors.textSecondary.withValues(alpha: 0.2),
        thickness: 1,
        space: 0,
      ),

      // ── Tab Bar ──
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.accent,
      ),

      // ── Dropdown ──
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
            borderSide: const BorderSide(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.darkSurface,
        secondary: AppColors.secondary,
        onSecondary: AppColors.surface,
        surface: AppColors.darkSurface,
        onSurface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.primary,
      textTheme: GoogleFonts.poppinsTextTheme(
        _buildTextTheme(),
      ).apply(bodyColor: AppColors.surface, displayColor: AppColors.surface),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.surface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.accentDark.withValues(alpha: 0.1),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.surface,
        elevation: 8,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    const baseStyle = TextStyle(
      fontFamily: 'System',
      color: AppColors.textPrimary,
      letterSpacing: -0.2,
    );

    return TextTheme(
      displayLarge: baseStyle.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displayMedium: baseStyle.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displaySmall: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: baseStyle.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: baseStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
      bodyLarge: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodySmall: baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: baseStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }
}
