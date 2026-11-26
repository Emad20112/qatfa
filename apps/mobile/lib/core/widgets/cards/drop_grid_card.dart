import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/qatfa_phone_button.dart';
import '../buttons/qatfa_whatsapp_button.dart';
import '../chips/qatfa_status_badge.dart';

/// بطاقة القطفة اليومية في الشبكة الرئيسية (Daily Drop Grid Card)
/// تطابق تماماً التصميم البصري للبطاقة في الصورة 4
class DropGridCard extends StatelessWidget {
  final String title;
  final String sellerName;
  final String price;
  final String? oldPrice;
  final String? imageUrl;
  final String phoneNumber;
  final VoidCallback onTap;
  final bool isFresh;

  const DropGridCard({
    super.key,
    required this.title,
    required this.sellerName,
    required this.price,
    this.oldPrice,
    this.imageUrl,
    required this.phoneNumber,
    required this.onTap,
    this.isFresh = true,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حاوية الصورة وشارة الطزاجة
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.25,
                  child: Container(
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
                if (isFresh)
                  const Positioned(
                    top: AppSpacing.s8,
                    left: AppSpacing.s8,
                    child: QatfaStatusBadge(
                      label: 'طازج الآن',
                      statusType: QatfaStatusType.fresh,
                      showDot: true,
                    ),
                  ),
              ],
            ),

            // البيانات النصية والتسعير
            Padding(
              padding: AppSpacing.p12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الصنف
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),

                  // اسم المقاوتي
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 14, color: colors.textSecondary),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Text(
                          sellerName,
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
                  const SizedBox(height: AppSpacing.s8),

                  // السعر بالريال اليمني
                  Row(
                    children: [
                      Text(
                        '$price ر.ي',
                        style: AppTypography.priceTagMedium(color: colors.agate),
                      ),
                      if (oldPrice != null) ...[
                        const SizedBox(width: AppSpacing.s6),
                        Text(
                          '$oldPrice ر.ي',
                          style: AppTypography.strikethroughPrice(color: colors.textMuted),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s10),

                  // زرا الاتصال السريع والواتساب
                  Row(
                    children: [
                      QatfaPhoneButton(
                        phoneNumber: phoneNumber,
                        isCircle: true,
                        size: 36,
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      Expanded(
                        child: QatfaWhatsAppButton(
                          phoneNumber: phoneNumber,
                          dropTitle: title,
                          price: '$price ر.ي',
                          height: 36,
                          isCompact: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(QatfaColors colors) {
    return Center(
      child: Icon(
        Icons.eco_rounded,
        size: 38,
        color: colors.primary.withValues(alpha: 0.3),
      ),
    );
  }
}
