import 'package:flutter/material.dart';

/// نظام المسافات والأبعاد وأنصاف الأقطار الموحد لمنصة قطفة
/// مبني على قاعدة مضاعفات الـ 4dp لضمان تناسق بصري فائق على مختلف الشاشات
class AppSpacing {
  AppSpacing._();

  // ---------------------------------------------------------------------------
  // ثوابت المسافات الرقمية (Grid Units)
  // ---------------------------------------------------------------------------
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;

  // ---------------------------------------------------------------------------
  // ثوابت الحشو المتكررة (EdgeInsets)
  // ---------------------------------------------------------------------------
  static const EdgeInsets p4 = EdgeInsets.all(s4);
  static const EdgeInsets p8 = EdgeInsets.all(s8);
  static const EdgeInsets p12 = EdgeInsets.all(s12);
  static const EdgeInsets p16 = EdgeInsets.all(s16);
  static const EdgeInsets p20 = EdgeInsets.all(s20);
  static const EdgeInsets p24 = EdgeInsets.all(s24);

  static const EdgeInsets ph16 = EdgeInsets.symmetric(horizontal: s16);
  static const EdgeInsets ph20 = EdgeInsets.symmetric(horizontal: s20);
  static const EdgeInsets pv8 = EdgeInsets.symmetric(vertical: s8);
  static const EdgeInsets pv12 = EdgeInsets.symmetric(vertical: s12);
  static const EdgeInsets pv16 = EdgeInsets.symmetric(vertical: s16);

  static const EdgeInsets cardPadding = EdgeInsets.all(s12);
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: s16, vertical: s12);

  // ---------------------------------------------------------------------------
  // أنصاف أقطار الزوايا (Border Radii)
  // ---------------------------------------------------------------------------
  static const double r4 = 4.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double rFull = 999.0;

  static const BorderRadius radius8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius radius12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius radius16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius radius20 = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius radius24 = BorderRadius.all(Radius.circular(r24));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(rFull));
}
