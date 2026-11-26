import 'package:flutter/material.dart';

/// نظام التيبوجرافي والخطوط المعتمد لمنصة قطفة (Typography Scale)
/// يعتمد على خط Cairo العربي الهندسي عالي الوضوح في الهواتف الاقتصادية
/// يعمل بشكل كامل دون الاعتماد على طلبات HTTP لحظية لضمان عمل التطبيق في وضع عدم الاتصال
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Cairo';
  static const List<String> fontFallbacks = ['Cairo', 'Almarai', 'sans-serif'];

  /// إنشاء شجرة TextTheme المتكاملة مع الألوان المحددة
  static TextTheme createTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      // العناوين الكبرى الرئيسية (24sp)
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: primaryTextColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: primaryTextColor,
      ),

      // عناوين الشاشات والأسواق الرئيسية (18sp - 20sp)
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: primaryTextColor,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primaryTextColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primaryTextColor,
      ),

      // نصوص المحتوى والأوصاف (13sp - 15sp)
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primaryTextColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: secondaryTextColor,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryTextColor,
      ),

      // الشارات والأزرار (11sp - 14sp)
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: primaryTextColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: secondaryTextColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: secondaryTextColor,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // أنماط مخصصة مميزة لأسعار القات والشارات
  // ---------------------------------------------------------------------------

  /// نمط سعر القطفة البارز بالريال اليمني في شاشة التفاصيل (22sp ExtraBold)
  static TextStyle priceTagLarge({required Color color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      height: 1.2,
      color: color,
    );
  }

  /// نمط سعر القطفة في البطاقات الشبكية الرئيسية (16sp Bold)
  static TextStyle priceTagMedium({required Color color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: color,
    );
  }

  /// نمط السعر السابق المشطوب قبل التخفيض
  static TextStyle strikethroughPrice({required Color color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.lineThrough,
      decorationColor: color,
      color: color,
    );
  }

  /// نمط نص زر محادثة الواتساب
  static TextStyle actionButton({required Color color, double fontSize = 14}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallbacks,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: color,
    );
  }
}
