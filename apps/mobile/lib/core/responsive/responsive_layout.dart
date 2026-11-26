import 'package:flutter/material.dart';
import 'screen_breakpoints.dart';

/// ويدجت تكيفي يستند إلى قياس المساحة المتاحة (LayoutBuilder)
/// وفق توصيات مهارة flutter-build-responsive-layout
class ResponsiveLayout extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ScreenBreakpoints.desktopMin && desktop != null) {
          return desktop!(context);
        }
        if (constraints.maxWidth >= ScreenBreakpoints.tabletMin && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}
