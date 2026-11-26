import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// رقاقة تصنيف واختيار مرنة للأصناف والمحافظات (Choice Chip)
class QatfaChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Widget? avatar;

  const QatfaChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: isSelected ? colors.primary : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.radiusFull,
        side: BorderSide(
          color: isSelected ? colors.primary : colors.border,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onSelected(!isSelected),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatar != null) ...[
                avatar!,
                const SizedBox(width: AppSpacing.s6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
