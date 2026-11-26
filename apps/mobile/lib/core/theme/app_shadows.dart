import 'package:flutter/material.dart';

/// نظام الظلال المعتمد لبطاقات وعناصر واجهات قطفة
class AppShadows {
  AppShadows._();

  /// ظل ناعم خفيف للبطاقات في الوضع الفاتح
  static const List<BoxShadow> lightCard = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// ظل بارز للمكونات المرتفعة كالأزرار العائمة وشريط التنقل
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// توهج برتقالي خفيف لزر عرض القطفة العائم
  static const List<BoxShadow> orangeGlow = [
    BoxShadow(
      color: Color(0x59E65100),
      offset: Offset(0, 4),
      blurRadius: 14,
      spreadRadius: 2,
    ),
  ];

  /// في الوضع الداكن: استبدال الظلال المظلمة بحدود واضحة أو توهج ناعم جداً
  static const List<BoxShadow> darkCard = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
}
