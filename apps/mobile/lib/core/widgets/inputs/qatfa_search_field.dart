import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// حقل البحث البيضاوي المخصص مع زر الفلترة (Search & Filter Bar)
class QatfaSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSubmitted;
  final String hintText;
  final bool autoFocus;

  const QatfaSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onSubmitted,
    this.hintText = 'ابحث عن نوع القات (همداني، أرحبي، شامي...) أو المقاوتي...',
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppSpacing.radiusFull,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.s12),
          Icon(
            Icons.search_rounded,
            color: colors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autoFocus,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted?.call(),
              style: TextStyle(
                fontSize: 13,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: colors.textMuted,
                ),
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            Container(
              height: 24,
              width: 1,
              color: colors.border,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            ),
            IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: colors.primary,
                size: 20,
              ),
              onPressed: onFilterTap,
              tooltip: 'الفلترة الذكية',
            ),
          ] else ...[
            const SizedBox(width: AppSpacing.s12),
          ],
        ],
      ),
    );
  }
}
