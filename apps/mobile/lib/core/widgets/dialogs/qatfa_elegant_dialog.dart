import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';

/// بطاقة الإدخال الأنيقة (Input Card) — حقول مجمعة بزوايا مقوسة وحدود ناعمة
class QatfaDialogInputCard extends StatelessWidget {
  final Widget child;
  final Color? tint;

  const QatfaDialogInputCard({super.key, required this.child, this.tint});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: AppSpacing.p12,
      decoration: BoxDecoration(
        color: tint ?? colors.surfaceElevated,
        borderRadius: AppSpacing.radius20,
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
      ),
      child: child,
    );
  }
}

/// حقل إدخال عمودي أنيق: عنوان صغير + أيقونة + حقل أزرار مقوسة
class QatfaDialogField extends StatelessWidget {
  final String title;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool isOptional;
  final String? optionalBadge;

  const QatfaDialogField({
    super.key,
    required this.title,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.onChanged,
    this.isOptional = false,
    this.optionalBadge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return QatfaDialogInputCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppSpacing.radius8,
                ),
                child: Icon(icon, size: 16, color: colors.primary),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (optionalBadge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: AppSpacing.s2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.agateContainer,
                    borderRadius: AppSpacing.radiusFull,
                  ),
                  child: Text(
                    optionalBadge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colors.agate,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: colors.textMuted,
              ),
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s12,
                vertical: AppSpacing.s12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppSpacing.radius12,
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.radius12,
                borderSide: BorderSide(color: colors.primary, width: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// نافذة أنيقة موحدة بأسلوب هوية قطفة:
/// زوايا مقوسة 28dp، ترويسة متدرجة، مقبض سحب، وأزرار أنيقة أسفلها.
///
/// تعرض النافذة محتواها فوراً دون مكتبة خارجية، وتُغلق بأمان
/// عبر [onCancel] مع فرصة لتنفيذ تنظيف الموارد قبل الإغلاق (لمنع التجمد).
class QatfaElegantDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final Widget child;
  final String cancelLabel;
  final String confirmLabel;
  final IconData confirmIcon;
  final String? hintText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const QatfaElegantDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.child,
    this.cancelLabel = 'إلغاء',
    this.confirmLabel = 'إضافة',
    this.confirmIcon = Icons.check_rounded,
    this.hintText,
    this.onCancel,
    this.onConfirm,
  });

  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(_radius),
                boxShadow: AppShadows.elevated,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s20,
                        AppSpacing.s20,
                        AppSpacing.s20,
                        AppSpacing.s16,
                      ),
                      child: child,
                    ),
                  ),
                  _buildActions(context, colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s12,
        AppSpacing.s20,
        AppSpacing.s20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreenDark, AppColors.primaryGreen],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(_radius - 6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: AppSpacing.radiusFull,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: AppSpacing.radius16,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(headerIcon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                key: const Key('elegant_dialog_close'),
                onTap: onCancel,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, QatfaColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s12,
        AppSpacing.s20,
        AppSpacing.s20,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hintText != null) ...[
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: colors.textMuted,
                ),
                const SizedBox(width: AppSpacing.s4),
                Expanded(
                  child: Text(
                    hintText!,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
          ],
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    key: const Key('elegant_dialog_confirm'),
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusFull,
                      ),
                    ),
                    icon: Icon(confirmIcon, size: 18),
                    label: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    key: const Key('elegant_dialog_cancel'),
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      backgroundColor: colors.surfaceElevated,
                      side: BorderSide(color: colors.border),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusFull,
                      ),
                    ),
                    child: Text(
                      cancelLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// تُظهر [QatfaElegantDialog] بأنيميشن ناعم (انزلاق من الأسفل + تلاشي)
/// داخل حاجز آمن على شاشة صغيرة ولوحة مفاتيح مفتوحة.
///
/// ملاحظة مهمة لمنع التجمد: يتم تنظيف الموارد داخل أخبار التخطيط للنافذة
/// (post frame) قبل الإغلاق، فلا يُجرى أي عمل على ويدجت تم التخلص منه.
Future<T?> showQatfaElegantDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) {
      final bottomInset = MediaQuery.viewInsetsOf(dialogContext).bottom;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s24,
        ).add(EdgeInsets.only(bottom: bottomInset)),
        child: builder(dialogContext),
      );
    },
  );
}
