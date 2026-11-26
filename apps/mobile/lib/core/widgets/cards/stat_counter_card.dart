import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// بطاقة عداد الإحصائيات ثلاثية الأعمدة (3-Column Stat Counter)
/// تطابق التصميم البصري في شاشة الحساب (الصورة 1) وشاشة التفاصيل (الصورة 5)
class StatCounterCard extends StatelessWidget {
  final List<StatItem> items;

  const StatCounterCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: AppSpacing.pv12,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppSpacing.radius16,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(items[i].icon, size: 20, color: items[i].iconColor ?? colors.primary),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    items[i].value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    items[i].label,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              Container(
                width: 1,
                height: 36,
                color: colors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });
}
