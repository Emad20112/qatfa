import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// مكون التحميل الهيكلي الشبحي (Skeleton Shimmer Box)
/// بديل لمؤشرات التحميل التقليدية لضمان أداء فائق على شبكات الـ 3G
class QatfaShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const QatfaShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<QatfaShimmerBox> createState() => _QatfaShimmerBoxState();
}

class _QatfaShimmerBoxState extends State<QatfaShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.surfaceElevated.withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? AppSpacing.radius12,
          ),
        );
      },
    );
  }
}
