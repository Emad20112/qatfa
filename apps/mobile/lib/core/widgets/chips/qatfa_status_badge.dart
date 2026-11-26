import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// أنواع حالات القطفات والحجوزات
enum QatfaStatusType {
  fresh,       // طازج الآن (أخضر نضر)
  active,      // نشط الآن في السوق
  pending,     // قيد التأكيد (برتقالي / أصفر تحذيري)
  confirmed,   // مؤكد (أخضر زمردي)
  completed,   // مكتمل (أخضر هادئ)
  soldOut,     // نفدت الكمية (أحمر)
}

/// شارة الحالة الذكية الملونة (Status Badge)
class QatfaStatusBadge extends StatelessWidget {
  final String label;
  final QatfaStatusType statusType;
  final bool showDot;

  const QatfaStatusBadge({
    super.key,
    required this.label,
    required this.statusType,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color bg;
    Color fg;

    switch (statusType) {
      case QatfaStatusType.fresh:
      case QatfaStatusType.active:
        bg = colors.statusFresh.withValues(alpha: 0.15);
        fg = colors.statusFresh;
        break;
      case QatfaStatusType.pending:
        bg = colors.statusPending.withValues(alpha: 0.15);
        fg = colors.statusPending;
        break;
      case QatfaStatusType.confirmed:
        bg = colors.statusConfirmed.withValues(alpha: 0.15);
        fg = colors.statusConfirmed;
        break;
      case QatfaStatusType.completed:
        bg = colors.primary.withValues(alpha: 0.12);
        fg = colors.primary;
        break;
      case QatfaStatusType.soldOut:
        bg = colors.statusSoldOut.withValues(alpha: 0.15);
        fg = colors.statusSoldOut;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.s4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
