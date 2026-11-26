import 'package:flutter/material.dart';

/// نقاط التحول والتجاوب لأحجام الشاشات المختلفة (Breakpoints)
/// متوافقة مع ممارسات فلاتر الحديثة وتدعم الهواتف والأجهزة اللوحية
class ScreenBreakpoints {
  ScreenBreakpoints._();

  static const double mobileMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;

  /// فحص هل الشاشة هاتف محمول
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width <= mobileMax;
  }

  /// فحص هل الشاشة جهاز لوحي (Tablet)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletMin && width <= tabletMax;
  }

  /// فحص هل الشاشة شاشة عريضة (Desktop / Web)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopMin;
  }
}
