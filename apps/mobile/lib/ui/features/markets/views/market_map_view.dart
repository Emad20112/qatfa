import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/qatfa_phone_button.dart';
import '../../../../core/widgets/buttons/qatfa_whatsapp_button.dart';
import '../../../../core/widgets/chips/qatfa_status_badge.dart';
import '../../../../data/models/qatfa_models.dart';
import '../../../../data/services/mock_qatfa_data.dart';

/// شاشة خريطة السوق التفاعلية ومواقع المفارش (MarketMapView)
class MarketMapView extends StatefulWidget {
  final MarketItem market;

  const MarketMapView({super.key, required this.market});

  @override
  State<MarketMapView> createState() => _MarketMapViewState();
}

class _MarketMapViewState extends State<MarketMapView> {
  StallItem? _selectedStall;

  @override
  void initState() {
    super.initState();
    // تحديد أول مفرش متوفر افتراضياً
    _selectedStall = MockQatfaData.stalls.firstWhere(
      (s) => s.isAvailable,
      orElse: () => MockQatfaData.stalls.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surfaceElevated,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'خريطة ${widget.market.name}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            Text(
              '${widget.market.city} — مواقع المفارش وحالة التوفر',
              style: TextStyle(fontSize: 11, color: colors.textSecondary),
            ),
          ],
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // لوحة الخريطة التفاعلية التراثية الخفيفة
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE8ECEF),
              child: Stack(
                children: [
                  // شبكة الشوارع وأزقة السوق المرسومة هندسياً
                  CustomPaint(
                    size: Size.infinite,
                    painter: _MarketGridPainter(primaryColor: colors.primary),
                  ),

                  // مؤشر بوابات السوق
                  Positioned(
                    top: 24,
                    left: 24,
                    child: _buildGateBadge('البوابة الغربية الرئيسية'),
                  ),
                  Positioned(
                    bottom: 240,
                    right: 24,
                    child: _buildGateBadge('بوابة الكريمي ومسجد السوق'),
                  ),

                  // دبابيس المفارش داخل السوق
                  ...MockQatfaData.stalls.map((stall) {
                    final isSelected = _selectedStall?.id == stall.id;

                    return Align(
                      alignment: FractionalOffset(
                        stall.longitudeOffset,
                        stall.latitudeOffset,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedStall = stall);
                        },
                        child: _buildStallPin(stall, isSelected),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // زر عائم لتحديد الموقع الحالي
          Positioned(
            top: AppSpacing.s16,
            left: AppSpacing.s16,
            child: FloatingActionButton.extended(
              heroTag: 'my_location_btn',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديد موقعك داخل السوق بدقة 🧭'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: colors.surface,
              foregroundColor: colors.primary,
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: const Text(
                'موقعي الحالي',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // بطاقة المعاينة المنبثقة السريعة أسفل الشاشة للمفرش المحدد
          if (_selectedStall != null)
            Positioned(
              left: AppSpacing.s16,
              right: AppSpacing.s16,
              bottom: AppSpacing.s16,
              child: _buildBottomStallCard(_selectedStall!, colors),
            ),
        ],
      ),
    );
  }

  Widget _buildGateBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: AppSpacing.radiusFull,
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.meeting_room_outlined,
            size: 14,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: AppSpacing.s4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStallPin(StallItem stall, bool isSelected) {
    final isAvailable = stall.isAvailable;
    final pinColor = isAvailable
        ? const Color(0xFF2E7D32)
        : const Color(0xFF757575);

    return AnimatedScale(
      scale: isSelected ? 1.25 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: AppSpacing.radiusFull,
              border: Border.all(color: pinColor, width: isSelected ? 2 : 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: pinColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(
                  'مفرش ${stall.stallNumber}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.black87 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.location_on_rounded,
            size: isSelected ? 32 : 26,
            color: pinColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStallCard(StallItem stall, QatfaColors colors) {
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.radius20,
        side: BorderSide(color: colors.border, width: 1),
      ),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppSpacing.p16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة القات بالمفرش
                ClipRRect(
                  borderRadius: AppSpacing.radius12,
                  child: Container(
                    width: 70,
                    height: 70,
                    color: colors.surfaceElevated,
                    child: stall.dropImageUrl != null
                        ? Image.network(
                            stall.dropImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.eco_rounded,
                              color: Colors.green,
                            ),
                          )
                        : const Icon(Icons.eco_rounded, color: Colors.green),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),

                // تفاصيل المفرش
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stall.sellerName,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          QatfaStatusBadge(
                            label: stall.isAvailable
                                ? 'متوفر الآن'
                                : 'نفدت الكمية',
                            statusType: stall.isAvailable
                                ? QatfaStatusType.fresh
                                : QatfaStatusType.soldOut,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),

                      Text(
                        stall.dropTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),

                      Row(
                        children: [
                          Text(
                            '${stall.price} ريال',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          Text(
                            ' / ${stall.unit}',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          if (stall.isVerified)
                            Row(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: AppSpacing.s2),
                                Text(
                                  'رقم موثق',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),

            // أزرار التواصل المباشر
            Row(
              children: [
                Expanded(
                  child: QatfaWhatsAppButton(
                    phoneNumber: stall.phoneNumber,
                    dropTitle: stall.dropTitle,
                    price: '${stall.price} ريال',
                    label: 'مراسلة واتساب',
                    height: 40,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                QatfaPhoneButton(
                  phoneNumber: stall.phoneNumber,
                  isCircle: true,
                  size: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// راسم شبكة السوق التراثية الخفيفة
class _MarketGridPainter extends CustomPainter {
  final Color primaryColor;

  _MarketGridPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final boundaryPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // رسم مساحة السوق المركزية
    final marketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
      const Radius.circular(24),
    );
    canvas.drawRRect(marketRect, boundaryPaint);

    // الشارع الرئيسي
    final mainRoad = Path()
      ..moveTo(size.width * 0.15, 0)
      ..lineTo(size.width * 0.85, size.height);
    canvas.drawPath(mainRoad, roadPaint);

    // الشارع المتقاطع
    final crossRoad = Path()
      ..moveTo(0, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.55);
    canvas.drawPath(crossRoad, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
