import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/qatfa_phone_button.dart';
import '../chips/qatfa_status_badge.dart';

/// بطاقة الحجز وسجل المتابعة (Booking & Inquiries Card)
/// تطابق التصميم البصري في الصورة 3
class BookingCard extends StatelessWidget {
  final String title;
  final String sellerName;
  final String price;
  final String quantity;
  final String dateText;
  final String expectedTimeText;
  final QatfaStatusType statusType;
  final String statusLabel;
  final String phoneNumber;
  final VoidCallback? onCancelTap;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onRateTap;

  const BookingCard({
    super.key,
    required this.title,
    required this.sellerName,
    required this.price,
    this.quantity = '1 حزمة (كيلو)',
    required this.dateText,
    required this.expectedTimeText,
    required this.statusType,
    required this.statusLabel,
    required this.phoneNumber,
    this.onCancelTap,
    this.onDetailsTap,
    this.onRateTap,
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
      child: Padding(
        padding: AppSpacing.p12,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة مصغرة
                ClipRRect(
                  borderRadius: AppSpacing.radius12,
                  child: Container(
                    width: 70,
                    height: 70,
                    color: colors.surfaceElevated,
                    child: Center(
                      child: Icon(
                        Icons.eco_rounded,
                        size: 28,
                        color: colors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),

                // البيانات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 14, color: colors.textSecondary),
                          const SizedBox(width: AppSpacing.s4),
                          Text(
                            sellerName,
                            style: TextStyle(fontSize: 12, color: colors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        '$price ر.ي',
                        style: AppTypography.priceTagMedium(color: colors.agate),
                      ),
                      Text(
                        'الكمية: $quantity',
                        style: TextStyle(fontSize: 11, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),

                // شارة الحالة وتاريخ الحجز
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    QatfaStatusBadge(
                      label: statusLabel,
                      statusType: statusType,
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dateText,
                          style: TextStyle(fontSize: 10.5, color: colors.textSecondary),
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        Icon(Icons.calendar_today_outlined, size: 12, color: colors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      expectedTimeText,
                      style: TextStyle(fontSize: 10, color: colors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),

            // خط فاصل ناعم
            Divider(height: 1, color: colors.border),
            const SizedBox(height: AppSpacing.s8),

            // أزرار الإجراء السفلية بحسب الحالة
            _buildActionButtons(context, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, QatfaColors colors) {
    if (statusType == QatfaStatusType.completed) {
      return SizedBox(
        width: double.infinity,
        height: 38,
        child: OutlinedButton.icon(
          onPressed: onRateTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
            shape: const RoundedRectangleBorder(borderRadius: AppSpacing.radiusFull),
          ),
          icon: const Icon(Icons.star_outline_rounded, size: 16),
          label: Text('تقييم التجربة', style: TextStyle(color: colors.primary, fontSize: 13)),
        ),
      );
    }

    return Row(
      children: [
        if (statusType == QatfaStatusType.pending && onCancelTap != null)
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextButton.icon(
                onPressed: onCancelTap,
                style: TextButton.styleFrom(
                  backgroundColor: colors.statusSoldOut.withValues(alpha: 0.1),
                  foregroundColor: colors.statusSoldOut,
                  shape: const RoundedRectangleBorder(borderRadius: AppSpacing.radiusFull),
                ),
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('إلغاء الحجز', style: TextStyle(fontSize: 12.5)),
              ),
            ),
          )
        else if (statusType == QatfaStatusType.confirmed)
          Expanded(
            child: QatfaPhoneButton(
              phoneNumber: phoneNumber,
              label: 'اتصال بالمقاوتي',
              isCircle: false,
              size: 38,
            ),
          ),
        const SizedBox(width: AppSpacing.s8),
        if (onDetailsTap != null)
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextButton(
                onPressed: onDetailsTap,
                style: TextButton.styleFrom(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.primary,
                  shape: const RoundedRectangleBorder(borderRadius: AppSpacing.radiusFull),
                ),
                child: const Text('عرض التفاصيل', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }
}
