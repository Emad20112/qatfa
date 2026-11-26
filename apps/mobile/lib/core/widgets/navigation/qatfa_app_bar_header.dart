import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// الترويسة العلوية التراثية المتدرجة بالأخضر القاتمي (Heritage App Bar Header)
/// تطابق الشريط العلوي الأخضر في جميع صور التطبيق
class QatfaAppBarHeader extends StatelessWidget {
  final String locationText;
  final int notificationCount;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final Widget? bottom;
  final double bottomHeight;

  const QatfaAppBarHeader({
    super.key,
    this.locationText = 'صنعاء',
    this.notificationCount = 3,
    this.onLocationTap,
    this.onNotificationTap,
    this.bottom,
    this.bottomHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreenDark, AppColors.primaryGreen],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: AppSpacing.ph16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.s8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // محدد المدينة / السوق الجغرافي
                  InkWell(
                    onTap: onLocationTap,
                    borderRadius: AppSpacing.radiusFull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: AppSpacing.radiusFull,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: AppSpacing.s4),
                          Text(
                            locationText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s2),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                  // شعار قطفة المركزي
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco_rounded, color: Color(0xFF4ADE80), size: 22),
                      const SizedBox(width: AppSpacing.s4),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'قـطـفـة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '— QATFA —',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFBBF7D0),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // جرس الإشعارات مع عداد التنبيهات
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: onNotificationTap,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                notificationCount > 9 ? '9+' : '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (bottom != null) ...[
                const SizedBox(height: AppSpacing.s12),
                bottom!,
              ],
              const SizedBox(height: AppSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }
}
