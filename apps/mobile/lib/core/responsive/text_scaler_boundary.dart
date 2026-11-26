import 'package:flutter/material.dart';

/// ويدجت تطويق وحماية مقياس الخط (TextScaler Clamping Boundary)
/// يضمن عدم حدوث انهيار للواجهات أو أخطاء RenderFlex overflow
/// إذا قام المستخدم بتكبير الخط بشكل مفرط من إعدادات الهاتف (Accessibility)
class TextScalerBoundary extends StatelessWidget {
  final Widget child;
  final double minScale;
  final double maxScale;

  const TextScalerBoundary({
    super.key,
    required this.child,
    this.minScale = 0.85,
    this.maxScale = 1.30,
  });

  @override
  Widget build(BuildContext context) {
    final currentScaler = MediaQuery.textScalerOf(context);
    final clampedScaler = currentScaler.clamp(
      minScaleFactor: minScale,
      maxScaleFactor: maxScale,
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: clampedScaler,
      ),
      child: child,
    );
  }
}
