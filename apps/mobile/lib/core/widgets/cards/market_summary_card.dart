import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../chips/qatfa_status_badge.dart';

/// بطاقة السوق في قائمة الأسواق الشعبية (Market Summary Card)
/// تطابق التصميم البصري للبطاقة في الصورة 2
class MarketSummaryCard extends StatelessWidget {
  final String marketName;
  final String location;
  final String rating;
  final String activeSellersCount;
  final String workingHours;
  final String? imageUrl;
  final VoidCallback onTap;

  const MarketSummaryCard({
    super.key,
    required this.marketName,
    required this.location,
    required this.rating,
    required this.activeSellersCount,
    required this.workingHours,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.radius16,
        side: BorderSide(color: colors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.p12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة السوق المصغرة مع شارة النشاط
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppSpacing.radius12,
                    child: Container(
                      width: 90,
                      height: 90,
                      color: colors.surfaceElevated,
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(colors),
                            )
                          : _buildPlaceholder(colors),
                    ),
                  ),
                  const Positioned(
                    top: 4,
                    left: 4,
                    child: QatfaStatusBadge(
                      label: 'نشط الآن',
                      statusType: QatfaStatusType.active,
                      showDot: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.s12),

              // التفاصيل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marketName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),

                    // الموقع
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: colors.primary),
                        const SizedBox(width: AppSpacing.s4),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),

                    // التقييم والمقاوتة
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: AppSpacing.s2),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Icon(Icons.people_outline_rounded, size: 14, color: colors.textSecondary),
                        const SizedBox(width: AppSpacing.s2),
                        Text(
                          '$activeSellersCount مقاوتي',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),

                    // ساعات العمل
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: colors.textSecondary),
                        const SizedBox(width: AppSpacing.s4),
                        Text(
                          workingHours,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // زر عرض السوق الجانبي
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.s16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: AppSpacing.radius12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'عرض',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    Icon(Icons.chevron_left_rounded, size: 16, color: colors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(QatfaColors colors) {
    return Center(
      child: Icon(
        Icons.storefront_rounded,
        size: 32,
        color: colors.primary.withValues(alpha: 0.3),
      ),
    );
  }
}
