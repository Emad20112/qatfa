import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// المنسق العام لثيم منصة قطفة (Material 3 Adaptive Themes)
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // الثيم الفاتح الافتراضي (Light Theme)
  // ---------------------------------------------------------------------------
  static ThemeData get light {
    final textTheme = AppTypography.createTextTheme(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryGreenLight,
      onPrimaryContainer: AppColors.primaryGreenDark,
      secondary: AppColors.freshGreen,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.freshGreenLight,
      onSecondaryContainer: AppColors.primaryGreenDark,
      tertiary: AppColors.agateOrange,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.agateOrangeLight,
      onTertiaryContainer: Color(0xFF6B2400),
      error: AppColors.statusDanger,
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurfaceElevated,
      outline: AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightScaffold,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,
      extensions: const [QatfaColors.light],

      // شريط التطبيق العلوي
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge,
      ),

      // بطاقات المحتوى
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radius16,
          side: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),

      // أزرار الحواف الدائرية
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusFull,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.lightTextMuted),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.radiusFull,
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusFull,
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusFull,
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
      ),

      // الرقاقات وفلاتر التصنيف
      chipTheme: ChipThemeData(
        elevation: 0,
        pressElevation: 0,
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusFull,
        ),
        labelStyle: textTheme.labelMedium,
      ),

      // شريط التنقل السفلي
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.lightTextMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // الثيم الداكن المنسجم مع ليل أسواق اليمن (Dark Night Theme)
  // ---------------------------------------------------------------------------
  static ThemeData get dark {
    final textTheme = AppTypography.createTextTheme(
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF22C55E),
      onPrimary: const Color(0xFF05200D),
      primaryContainer: const Color(0xFF14291B),
      onPrimaryContainer: const Color(0xFF86EFAC),
      secondary: const Color(0xFF4ADE80),
      onSecondary: const Color(0xFF05200D),
      secondaryContainer: const Color(0xFF133221),
      onSecondaryContainer: const Color(0xFFBBF7D0),
      tertiary: const Color(0xFFFB923C),
      onTertiary: const Color(0xFF331805),
      tertiaryContainer: const Color(0xFF431F07),
      onTertiaryContainer: const Color(0xFFFED7AA),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF391313),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceElevated,
      outline: AppColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkScaffold,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,
      extensions: const [QatfaColors.dark],

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge,
      ),

      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radius16,
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF22C55E),
          foregroundColor: const Color(0xFF05200D),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusFull,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.darkTextMuted),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.radiusFull,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusFull,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusFull,
          borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        elevation: 0,
        pressElevation: 0,
        backgroundColor: AppColors.darkSurface,
        selectedColor: const Color(0xFF14291B),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusFull,
        ),
        labelStyle: textTheme.labelMedium,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        selectedItemColor: Color(0xFF22C55E),
        unselectedItemColor: AppColors.darkTextMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
