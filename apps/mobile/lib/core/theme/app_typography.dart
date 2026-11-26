import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام التيبوجرافي والخطوط المعتمد لمنصة قطفة (Typography Scale)
/// يعتمد حصرياً على خط Cairo العربي الهندسي عالي الوضوح في الهواتف الاقتصادية
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Cairo';

  /// إنشاء شجرة TextTheme المتكاملة مع الألوان المحددة
  static TextTheme createTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      // العناوين الكبرى الرئيسية (24sp)
      displayLarge: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: primaryTextColor,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: primaryTextColor,
      ),

      // عناوين الشاشات والأسواق الرئيسية (18sp - 20sp)
      titleLarge: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: primaryTextColor,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primaryTextColor,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primaryTextColor,
      ),

      // نصوص المحتوى والأوصاف (13sp - 15sp)
      bodyLarge: GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primaryTextColor,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: secondaryTextColor,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryTextColor,
      ),

      // الشارات والأزرار (11sp - 14sp)
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: primaryTextColor,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: secondaryTextColor,
      ),
      labelSmall: GoogleFonts.cairo(
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
    return GoogleFonts.cairo(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      height: 1.2,
      color: color,
    );
  }

  /// نمط سعر القطفة في البطاقات الشبكية الرئيسية (16sp Bold)
  static TextStyle priceTagMedium({required Color color}) {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: color,
    );
  }

  /// نمط السعر السابق المشطوب قبل التخفيض
  static TextStyle strikethroughPrice({required Color color}) {
    return GoogleFonts.cairo(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.lineThrough,
      decorationColor: color,
      color: color,
    );
  }

  /// نمط نص زر محادثة الواتساب
  static TextStyle actionButton({required Color color, double fontSize = 14}) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: color,
    );
  }
}
