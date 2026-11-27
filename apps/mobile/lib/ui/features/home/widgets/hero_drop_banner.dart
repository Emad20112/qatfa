import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';

/// بانر العرض المميز البطل (Hero Featured Drop Card Banner)
/// يطابق البانر في الصورة 4 مع شارة التوقيت وزر نداء الإجراء العقيقي
class HeroDropBanner extends StatelessWidget {
  final VoidCallback onActionTap;

  const HeroDropBanner({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppSpacing.radius20,
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3813), Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: AppShadows.lightCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // نقوش وتأثيرات بصرية خفيفة في الخلفية
          Positioned(
            left: -20,
            bottom: -20,
            child: Icon(
              Icons.eco_rounded,
              size: 140,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),

          Padding(
            padding: AppSpacing.p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // الشارة الذهبية للتوقيت
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                    borderRadius: AppSpacing.radiusFull,
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: 13,
                        color: Color(0xFFFBBF24),
                      ),
                      SizedBox(width: AppSpacing.s4),
                      Text(
                        'وصل قبل 25 دقيقة — الكمية محدودة',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s10),

                // العنوان التسويقي البارز
                const Text(
                  'قطفة مميزة من أجود الأنواع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),

                // النص الفرعي
                Text(
                  'أرحبي قاعي سوبر فاخر بخصم حصري ومباشر من مفرش الحاج يحيى الصياح',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),

                // زر الإجراء العقيقي البرتقالي
                InkWell(
                  onTap: onActionTap,
                  borderRadius: AppSpacing.radiusFull,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.agateOrange, Color(0xFFFF6D00)],
                      ),
                      borderRadius: AppSpacing.radiusFull,
                      boxShadow: AppShadows.orangeGlow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'احجز حزمتك الآن',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
