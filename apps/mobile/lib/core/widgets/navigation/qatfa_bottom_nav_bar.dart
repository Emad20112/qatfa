import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';

/// شريط التنقل السفلي المطور لخمس وجهات مع الزر المرتفع في المنتصف (Custom Bottom Navigation Bar)
/// يطابق شريط التنقل في الصور 2 و 3 و 4
class QatfaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onPostDropTap;

  const QatfaBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onPostDropTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 1)),
        boxShadow: AppShadows.elevated,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // تبويب 1: الرئيسية
              _buildNavItem(
                index: 0,
                label: 'الرئيسية',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                colors: colors,
              ),

              // تبويب 2: الأسواق
              _buildNavItem(
                index: 1,
                label: 'الأسواق',
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront_rounded,
                colors: colors,
              ),

              // الزر العائم في المنتصف: اعرض قطفتك
              GestureDetector(
                onTap: onPostDropTap,
                child: Container(
                  width: 52,
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.agate, Color(0xFFFF6D00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.orangeGlow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              // تبويب 3: حجوزاتي
              _buildNavItem(
                index: 2,
                label: 'حجوزاتي',
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
                colors: colors,
              ),

              // تبويب 4: حسابي
              _buildNavItem(
                index: 3,
                label: 'حسابي',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required QatfaColors colors,
  }) {
    final isActive = currentIndex == index;
    final color = isActive ? colors.primary : colors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 16,
                height: 2.5,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 2.5),
          ],
        ),
      ),
    );
  }
}
