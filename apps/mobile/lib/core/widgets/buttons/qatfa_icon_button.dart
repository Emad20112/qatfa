import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// زر أيقوني دائري مخصص بتأثير زجاجي نصف شفاف أو حاوية ناعمة
/// يُستخدم لزر الرجوع، وزر المفضلة، والمشاركة في شريط التطبيق
class QatfaIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;

  const QatfaIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 40.0,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = backgroundColor ?? colors.surface.withValues(alpha: 0.85);
    final fg = iconColor ?? colors.textPrimary;

    return Material(
      color: bg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
