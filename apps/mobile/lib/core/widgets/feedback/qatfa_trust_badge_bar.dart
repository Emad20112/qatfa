import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// شريط ركائز الثقة الثلاثي (Trust Badges Bar)
/// يطابق الشريط الموجود أسفل البانر في الصورة 4 والصورة 5
class QatfaTrustBadgeBar extends StatelessWidget {
  const QatfaTrustBadgeBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.6),
        borderRadius: AppSpacing.radius12,
        border: Border.all(color: colors.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            icon: Icons.verified_user_rounded,
            label: 'مقاوتة موثقون ميدانياً',
            color: colors.primary,
          ),
          Container(width: 1, height: 16, color: colors.border),
          _buildItem(
            icon: Icons.access_time_rounded,
            label: 'قطفات اليوم فقط',
            color: colors.secondary,
          ),
          Container(width: 1, height: 16, color: colors.border),
          _buildItem(
            icon: Icons.camera_alt_outlined,
            label: 'صور حقيقية 100%',
            color: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.s4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
