import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/qatfa_icon_button.dart';
import '../../../../core/widgets/buttons/qatfa_phone_button.dart';
import '../../../../core/widgets/buttons/qatfa_whatsapp_button.dart';
import '../../../../core/widgets/chips/qatfa_status_badge.dart';
import '../../../../data/models/qatfa_models.dart';

/// شاشة تفاصيل القطفة الكاملة ومواصفاتها (DropDetailScreen)
/// مطابقة للصورة 5 في مجلد apps/mobile/images_ui/5778591430203871632_120.jpg
class DropDetailScreen extends StatefulWidget {
  final DropItem drop;

  const DropDetailScreen({super.key, required this.drop});

  @override
  State<DropDetailScreen> createState() => _DropDetailScreenState();
}

class _DropDetailScreenState extends State<DropDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    if (widget.drop.galleryImages.isNotEmpty) {
      _images = widget.drop.galleryImages;
    } else if (widget.drop.imageUrl != null) {
      _images = [widget.drop.imageUrl!];
    } else {
      _images = [
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
      ];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _shareSmartLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الرابط الذكي للقطفة: https://qatfa.ye/d/${widget.drop.id} 🔗',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openFullScreenViewer() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'معاينة (${_currentImageIndex + 1} / ${_images.length})',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          body: PageView.builder(
            itemCount: _images.length,
            controller: PageController(initialPage: _currentImageIndex),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    _images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final drop = widget.drop;

    // احتساب نسبة الخصم إن وجد
    int? discountPercentage;
    if (drop.oldPrice != null && drop.oldPrice! > drop.price) {
      discountPercentage =
          (((drop.oldPrice! - drop.price) / drop.oldPrice!) * 100).round();
    }

    return Scaffold(
      backgroundColor: colors.surfaceElevated,
      body: Stack(
        children: [
          // المحتوى القابل للتمرير
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. معرض الصور التفاعلي (Carousel)
                SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _images.length,
                        onPageChanged: (i) =>
                            setState(() => _currentImageIndex = i),
                        itemBuilder: (context, index) {
                          return Image.network(
                            _images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: colors.surfaceElevated,
                              child: const Icon(
                                Icons.eco_rounded,
                                size: 64,
                                color: Colors.green,
                              ),
                            ),
                          );
                        },
                      ),

                      // تظليل علوي ناعم خلف أزرار شريط التطبيق
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // شارة [ 📷 صورة حقيقية من السوق اليوم ]
                      Positioned(
                        bottom: AppSpacing.s12,
                        right: AppSpacing.s12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: AppSpacing.radiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                              SizedBox(width: AppSpacing.s4),
                              Text(
                                'صورة حقيقية من السوق اليوم',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // عداد الصور [ 1 / 3 ]
                      Positioned(
                        bottom: AppSpacing.s12,
                        left: AppSpacing.s12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: AppSpacing.radiusFull,
                          ),
                          child: Text(
                            '${_currentImageIndex + 1} / ${_images.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // زر تكبير ملء الشاشة
                      Positioned(
                        bottom: AppSpacing.s12,
                        left: 64,
                        child: GestureDetector(
                          onTap: _openFullScreenViewer,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // مؤشر النقاط السفلي للصور
                if (_images.length > 1) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_images.length, (i) {
                      final isCurrent = i == _currentImageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isCurrent ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isCurrent ? colors.primary : colors.border,
                          borderRadius: AppSpacing.radiusFull,
                        ),
                      );
                    }),
                  ),
                ],

                // تفاصيل وبيانات القطفة
                Padding(
                  padding: AppSpacing.p16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شارة الحالة والتوقيت
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          QatfaStatusBadge(
                            label: drop.isAvailable
                                ? 'متوفر الآن'
                                : 'نفدت الكمية',
                            statusType: drop.isAvailable
                                ? QatfaStatusType.fresh
                                : QatfaStatusType.soldOut,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: colors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.s4),
                              Text(
                                'تم التحديث ${drop.updatedAtText}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s10),

                      // عنوان القطفة
                      Text(
                        drop.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),

                      // السعر بالريال اليمني
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${drop.price} ريال',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          Text(
                            ' / ${drop.unit}',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (drop.oldPrice != null) ...[
                            const SizedBox(width: AppSpacing.s10),
                            Text(
                              '${drop.oldPrice} ر.ي',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          if (discountPercentage != null) ...[
                            const SizedBox(width: AppSpacing.s8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE65100)
                                    .withValues(alpha: 0.15),
                                borderRadius: AppSpacing.radiusFull,
                              ),
                              child: Text(
                                'خصم $discountPercentage%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),

                      // 2. بطاقة المقاوتي ومعلومات الثقة
                      _buildSellerCard(colors, drop),
                      const SizedBox(height: AppSpacing.s16),

                      // 3. العنوان الدقيق وموقع المفرش
                      _buildLocationCard(colors, drop),
                      const SizedBox(height: AppSpacing.s16),

                      // 4. مصفوفة صفات القطفة الأربعة
                      Text(
                        'مواصفات القطفة الفنية',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      _buildAttributesGrid(colors, drop),

                      // مسافة أمان للشريط السفلي الثابت
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // الشريط العلوي مع الأزرار الدائرية الشفافة
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QatfaIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      QatfaIconButton(
                        icon: Icons.share_outlined,
                        onPressed: _shareSmartLink,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      QatfaIconButton(
                        icon: _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        iconColor: _isFavorite ? Colors.red : null,
                        onPressed: () {
                          setState(() => _isFavorite = !_isFavorite);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // الشريط السفلي الثابت (Sticky Bottom Bar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyBottomBar(colors, drop),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(QatfaColors colors, DropItem drop) {
    return Container(
      padding: AppSpacing.p12,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppSpacing.radius16,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.primaryContainer,
            child: Icon(Icons.person_rounded, color: colors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      drop.sellerName,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    if (drop.isVerifiedSeller)
                      Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  'مقاوتي معتمد في ${drop.marketName}',
                  style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Text(
                      '${drop.rating} (${drop.reviewsCount} تقييم)',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Text(
                      '🛍️ +${drop.completedSales} مبيعة مكتملة',
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
        ],
      ),
    );
  }

  Widget _buildLocationCard(QatfaColors colors, DropItem drop) {
    return Container(
      padding: AppSpacing.p12,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppSpacing.radius16,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drop.stallLocation,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  '${drop.city} — متوفر للتسوق المباشر الآن',
                  style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesGrid(QatfaColors colors, DropItem drop) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.1,
      crossAxisSpacing: AppSpacing.s12,
      mainAxisSpacing: AppSpacing.s12,
      children: [
        _buildAttributeItem(
          icon: Icons.eco_outlined,
          title: 'درجة النعومة',
          value: drop.freshnessLevel,
          colors: colors,
        ),
        _buildAttributeItem(
          icon: Icons.forest_outlined,
          title: 'نسبة العيدان',
          value: drop.leafToStemRatio,
          colors: colors,
        ),
        _buildAttributeItem(
          icon: Icons.calendar_today_outlined,
          title: 'وقت وتاريخ القطف',
          value: drop.harvestTimeText,
          colors: colors,
        ),
        _buildAttributeItem(
          icon: Icons.shield_outlined,
          title: 'طريقة الحفظ',
          value: drop.preservationMethod,
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildAttributeItem({
    required IconData icon,
    required String title,
    required String value,
    required QatfaColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppSpacing.radius12,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 10.5, color: colors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(QatfaColors colors, DropItem drop) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: AppShadows.elevated,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر الاتصال الهاتفي
            QatfaPhoneButton(
              phoneNumber: drop.sellerPhone,
              isCircle: false,
              label: 'اتصال',
              size: 48,
            ),
            const SizedBox(width: AppSpacing.s12),

            // زر المراسلة والحجز المباشر عبر واتساب
            Expanded(
              child: QatfaWhatsAppButton(
                phoneNumber: drop.sellerPhone,
                dropTitle: drop.title,
                price: '${drop.price} ريال',
                label: 'محادثة وحجز واتساب',
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
