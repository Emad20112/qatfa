import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// زر مراسلة وحجز الواتساب الفوري المجهز (WhatsApp Action Button)
/// يفتح فورياً محادثة الواتساب مع المقاوتي برسالة استفسار جاهزة
class QatfaWhatsAppButton extends StatelessWidget {
  final String phoneNumber;
  final String? dropTitle;
  final String? price;
  final String label;
  final double height;
  final double? width;
  final bool isCompact;

  const QatfaWhatsAppButton({
    super.key,
    required this.phoneNumber,
    this.dropTitle,
    this.price,
    this.label = 'حجز واتساب',
    this.height = 42.0,
    this.width,
    this.isCompact = false,
  });

  Future<void> _launchWhatsApp(BuildContext context) async {
    // تجهيز رقم الهاتف اليمني بالصيغة الدولية
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }
    if (!cleanNumber.startsWith('967')) {
      cleanNumber = '967$cleanNumber';
    }

    // تجهيز الرسالة المهذبة التلقائية
    String message = 'السلام عليكم يا غالي، أستفسر عن قطفة معروضة في تطبيق قطفة';
    if (dropTitle != null) {
      message += ' ($dropTitle)';
    }
    if (price != null) {
      message += ' بسعر $price';
    }
    message += '، هل لا زالت متوفرة؟';

    final uri = Uri.parse(
      'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // التعامل الصامت مع الأخطاء
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: () => _launchWhatsApp(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.whatsapp,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacing.s10 : AppSpacing.s16,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusFull,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white),
            const SizedBox(width: AppSpacing.s6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 12 : 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
