import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// زر الاتصال الهاتفي الفوري بالمقاوتي (Quick Phone Dial Button)
class QatfaPhoneButton extends StatelessWidget {
  final String phoneNumber;
  final String? label;
  final bool isCircle;
  final double size;

  const QatfaPhoneButton({
    super.key,
    required this.phoneNumber,
    this.label,
    this.isCircle = true,
    this.size = 42.0,
  });

  Future<void> _makeCall() async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isCircle) {
      return Material(
        color: colors.primaryContainer,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _makeCall,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.phone_rounded,
              color: colors.primary,
              size: 20,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: size,
      child: OutlinedButton.icon(
        onPressed: _makeCall,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.primary,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusFull,
          ),
          padding: AppSpacing.ph16,
        ),
        icon: Icon(Icons.phone_rounded, size: 18, color: colors.primary),
        label: Text(
          label ?? 'اتصال هاتفي',
          style: TextStyle(
            color: colors.primary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
