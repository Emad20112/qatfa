import 'package:flutter/material.dart';

/// نظام الألوان المعتمد لمنصة قطفة (Qatfa Color Tokens)
/// يجمع بين الأصالة التراثية اليمنية والتباين العالي المخصص للشارع وشمس الظهيرة
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // الألوان الأساسية التراثية (Brand Heritage Colors)
  // ---------------------------------------------------------------------------
  /// الأخضر القاتمي الأساسي - يمثل أصالة المحصول ومزارع اليمن
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryGreenDark = Color(0xFF0E3813);
  static const Color primaryGreenLight = Color(0xFFE8F5E9);

  /// الأخضر النضر - يمثل طزاجة القطفة وعلامات التوفر
  static const Color freshGreen = Color(0xFF2E7D32);
  static const Color freshGreenLight = Color(0xFFDCFCE7);

  /// برتقالي العقيق اليماني - اللون التفاعلي البارز للأزرار والأسعار
  static const Color agateOrange = Color(0xFFE65100);
  static const Color agateOrangeLight = Color(0xFFFFEDD5);

  /// أخضر الواتساب الرسمي - للمحادثة والحجز الفوري
  static const Color whatsappGreen = Color(0xFF25D366);

  // ---------------------------------------------------------------------------
  // الألوان الحيادية للوضع الفاتح (Light Palette)
  // ---------------------------------------------------------------------------
  static const Color lightScaffold = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F2);
  static const Color lightTextPrimary = Color(0xFF1A202C);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ---------------------------------------------------------------------------
  // الألوان الحيادية للوضع الداكن (Dark Night Palette)
  // مستوحى من هدوء ليل المدرجات الجبلية اليمنية
  // ---------------------------------------------------------------------------
  static const Color darkScaffold = Color(0xFF0A110D);
  static const Color darkSurface = Color(0xFF132219);
  static const Color darkSurfaceElevated = Color(0xFF1C3024);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF243B2D);

  // ---------------------------------------------------------------------------
  // ألوان الحالات الوظيفية (Status Colors)
  // ---------------------------------------------------------------------------
  static const Color statusSuccess = Color(0xFF16A34A);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusWarningLight = Color(0xFFFEF3C7);
  static const Color statusDanger = Color(0xFFDC2626);
  static const Color statusDangerLight = Color(0xFFFEE2E2);
  static const Color statusInfo = Color(0xFF0284C7);
  static const Color statusInfoLight = Color(0xFFE0F2FE);
}

/// امتداد ثيم قطفة المخصص لتوفير الوصول السلس للألوان في أي ويدجت
class QatfaColors extends ThemeExtension<QatfaColors> {
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color agate;
  final Color agateContainer;
  final Color whatsapp;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color statusFresh;
  final Color statusPending;
  final Color statusConfirmed;
  final Color statusCompleted;
  final Color statusSoldOut;

  const QatfaColors({
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.agate,
    required this.agateContainer,
    required this.whatsapp,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.statusFresh,
    required this.statusPending,
    required this.statusConfirmed,
    required this.statusCompleted,
    required this.statusSoldOut,
  });

  /// الباليت الفاتحة الافتراضية
  static const light = QatfaColors(
    primary: AppColors.primaryGreen,
    primaryContainer: AppColors.primaryGreenLight,
    secondary: AppColors.freshGreen,
    agate: AppColors.agateOrange,
    agateContainer: AppColors.agateOrangeLight,
    whatsapp: AppColors.whatsappGreen,
    surface: AppColors.lightSurface,
    surfaceElevated: AppColors.lightSurfaceElevated,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    border: AppColors.lightBorder,
    statusFresh: AppColors.freshGreen,
    statusPending: AppColors.statusWarning,
    statusConfirmed: AppColors.statusSuccess,
    statusCompleted: AppColors.primaryGreen,
    statusSoldOut: AppColors.statusDanger,
  );

  /// الباليت الداكنة المتناسقة مع هوية الطبيعة اليمنية ليلاً
  static const dark = QatfaColors(
    primary: Color(0xFF22C55E),
    primaryContainer: Color(0xFF14291B),
    secondary: Color(0xFF4ADE80),
    agate: Color(0xFFFB923C),
    agateContainer: Color(0xFF331805),
    whatsapp: Color(0xFF22C55E),
    surface: AppColors.darkSurface,
    surfaceElevated: AppColors.darkSurfaceElevated,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    border: AppColors.darkBorder,
    statusFresh: Color(0xFF4ADE80),
    statusPending: Color(0xFFFBBF24),
    statusConfirmed: Color(0xFF34D399),
    statusCompleted: Color(0xFF22C55E),
    statusSoldOut: Color(0xFFF87171),
  );

  @override
  QatfaColors copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? secondary,
    Color? agate,
    Color? agateContainer,
    Color? whatsapp,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? statusFresh,
    Color? statusPending,
    Color? statusConfirmed,
    Color? statusCompleted,
    Color? statusSoldOut,
  }) {
    return QatfaColors(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      agate: agate ?? this.agate,
      agateContainer: agateContainer ?? this.agateContainer,
      whatsapp: whatsapp ?? this.whatsapp,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      statusFresh: statusFresh ?? this.statusFresh,
      statusPending: statusPending ?? this.statusPending,
      statusConfirmed: statusConfirmed ?? this.statusConfirmed,
      statusCompleted: statusCompleted ?? this.statusCompleted,
      statusSoldOut: statusSoldOut ?? this.statusSoldOut,
    );
  }

  @override
  QatfaColors lerp(ThemeExtension<QatfaColors>? other, double t) {
    if (other is! QatfaColors) return this;
    return QatfaColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      agate: Color.lerp(agate, other.agate, t)!,
      agateContainer: Color.lerp(agateContainer, other.agateContainer, t)!,
      whatsapp: Color.lerp(whatsapp, other.whatsapp, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      statusFresh: Color.lerp(statusFresh, other.statusFresh, t)!,
      statusPending: Color.lerp(statusPending, other.statusPending, t)!,
      statusConfirmed: Color.lerp(statusConfirmed, other.statusConfirmed, t)!,
      statusCompleted: Color.lerp(statusCompleted, other.statusCompleted, t)!,
      statusSoldOut: Color.lerp(statusSoldOut, other.statusSoldOut, t)!,
    );
  }
}

/// ملحق وصول سريع للألوان من BuildContext
extension QatfaColorsX on BuildContext {
  QatfaColors get colors {
    return Theme.of(this).extension<QatfaColors>() ?? QatfaColors.light;
  }
}
