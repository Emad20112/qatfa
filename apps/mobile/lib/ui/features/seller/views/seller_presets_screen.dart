import 'package:flutter/material.dart';
import '../../../../core/responsive/text_scaler_boundary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/qatfa_icon_button.dart';
import '../../../../core/widgets/chips/qatfa_choice_chip.dart';
import '../../../../core/widgets/dialogs/qatfa_elegant_dialog.dart';
import '../view_models/seller_presets_view_model.dart';

/// شاشة إعداد القوائم السريعة المسبقة للمقاوتي (FR-STORE-08 / Flow 3.3)
/// تتيح تحديد الأنواع والأصناف والوحدات المتكررة لتظهر حصراً في نافذة النشر السريع
class SellerPresetsScreen extends StatefulWidget {
  final SellerPresetsViewModel? viewModel;

  const SellerPresetsScreen({
    super.key,
    this.viewModel,
  });

  @override
  State<SellerPresetsScreen> createState() => _SellerPresetsScreenState();
}

class _SellerPresetsScreenState extends State<SellerPresetsScreen>
    with SingleTickerProviderStateMixin {
  late final SellerPresetsViewModel _viewModel;
  late final bool _ownsViewModel;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? SellerPresetsViewModel();
    _viewModel.loadPresets();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _showAddCustomItemDialog() async {
    final typeController = TextEditingController();
    final gradeController = TextEditingController();
    final unitController = TextEditingController();

    void disposeControllers() {
      typeController.dispose();
      gradeController.dispose();
      unitController.dispose();
    }

    List<String> splitInput(String raw) => raw
        .split(RegExp(r'[,،\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    Widget buildContent(StateSetter setDialogState) {
      final colors = context.colors;
      final total = splitInput(typeController.text).length +
          splitInput(gradeController.text).length +
          splitInput(unitController.text).length;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QatfaDialogField(
            title: 'نوع قات',
            hintText: 'مثال: صعدي، مطري، سوتي',
            icon: Icons.eco_rounded,
            controller: typeController,
            onChanged: (_) => setDialogState(() {}),
          ),
          const SizedBox(height: AppSpacing.s10),
          QatfaDialogField(
            title: 'صنف / جودة',
            hintText: 'مثال: رووس، عوارض، قطل',
            icon: Icons.workspace_premium_rounded,
            controller: gradeController,
            onChanged: (_) => setDialogState(() {}),
          ),
          const SizedBox(height: AppSpacing.s10),
          QatfaDialogField(
            title: 'وحدة بيع',
            hintText: 'مثال: حبة، كيلو، قبضة',
            icon: Icons.scale_rounded,
            controller: unitController,
            optionalBadge: 'اختياري',
            onChanged: (_) => setDialogState(() {}),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            total == 0
                ? 'املأ حقلاً واحداً على الأقل، ويمكن الفصل بفاصلة لإضافة عدة أسماء.'
                : 'سيتم إضافة $total عنصر وتحديدها في قوائمك السريعة.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: total == 0 ? colors.textMuted : colors.primary,
            ),
          ),
        ],
      );
    }

    final result = await showQatfaElegantDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return QatfaElegantDialog(
              title: 'إضافة عنصر مخصص للقائمة',
              subtitle: 'أضف النوع والصنف والوحدة دفعة واحدة لتصبح جاهزة في نافذة النشر السريع.',
              headerIcon: Icons.playlist_add_rounded,
              confirmLabel: 'إضافة وتحديد',
              hintText: 'الفصل بفاصلة يضيف أكثر من عنصر في الحقل نفسه.',
              child: buildContent(setDialogState),
              // الإغلاق الآمن: نغلق النافذة أولاً ثم نحرر الموارد في الإطار التالي
              onCancel: () {
                Navigator.of(dialogContext).pop(false);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  disposeControllers();
                });
              },
              onConfirm: () {
                final hasAny = splitInput(typeController.text).isNotEmpty ||
                    splitInput(gradeController.text).isNotEmpty ||
                    splitInput(unitController.text).isNotEmpty;
                if (!hasAny) return;
                Navigator.of(dialogContext).pop(true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  disposeControllers();
                });
              },
            );
          },
        );
      },
    );

    if (result == true) {
      final types = splitInput(typeController.text);
      final grades = splitInput(gradeController.text);
      final units = splitInput(unitController.text);
      typeController.text = '';
      gradeController.text = '';
      unitController.text = '';
      await _viewModel.addCustomItems(
        qatTypes: types,
        qualityGrades: grades,
        saleUnits: units,
      );
    }
  }

  Future<void> _handleSave() async {
    final saved = await _viewModel.savePresets();
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ قوائمك السريعة بنجاح ⚡'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextScalerBoundary(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.primaryGreenDark,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(AppSpacing.s8),
              child: QatfaIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                iconColor: Colors.white,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            title: const Text(
              'إعداد القوائم السريعة لمفرشي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: AppSpacing.s12),
                child: TextButton.icon(
                  onPressed: _showAddCustomItemDialog,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.radiusFull,
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'إضافة مخصص',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final presets = _viewModel.presets;
              if (_viewModel.isLoading || presets == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: AppSpacing.p16,
                          children: [
                            // بطاقة الإضافة المخصصة السريعة في أعلى الشاشة
                            Material(
                              color: colors.primaryContainer,
                              borderRadius: AppSpacing.radius16,
                              child: InkWell(
                                onTap: _showAddCustomItemDialog,
                                borderRadius: AppSpacing.radius16,
                                child: Padding(
                                  padding: AppSpacing.p12,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: colors.primary,
                                          borderRadius: AppSpacing.radius12,
                                        ),
                                        child: const Icon(
                                          Icons.add_circle_outline_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.s12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '+ أضف نوع أو صنف أو وحدة جديدة',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: colors.primary,
                                              ),
                                            ),
                                            Text(
                                              'لإدراج أصناف مفرشك الخاصة غير الموجودة بالقائمة',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: colors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: colors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s12),

                            // بطاقة الشرح التوجيهية
                            Container(
                              padding: AppSpacing.p12,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: AppSpacing.radius16,
                                border: Border.all(color: colors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: colors.agate,
                                  ),
                                  const SizedBox(width: AppSpacing.s10),
                                  Expanded(
                                    child: Text(
                                      'حدد ما تبيعه بانتظام؛ لتظهر لك هذه الرقاقات فقط في نافذة النشر السريع وتنشر قطفتك في أقل من 30 ثانية.',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (_viewModel.statusMessage != null) ...[
                              const SizedBox(height: AppSpacing.s12),
                              Container(
                                padding: AppSpacing.p12,
                                decoration: BoxDecoration(
                                  color: colors.statusFresh.withValues(alpha: 0.12),
                                  borderRadius: AppSpacing.radius12,
                                ),
                                child: Text(
                                  _viewModel.statusMessage!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: colors.statusFresh,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.s20),

                            // 1. أنواع القات
                            _buildSectionCard(
                              context: context,
                              title: '1. أنواع القات التي تبيعها بانتظام',
                              subtitle:
                                  'المختار: ${presets.selectedTypes.length} من ${presets.availableTypes.length}',
                              items: presets.availableTypes,
                              selectedItems: presets.selectedTypes,
                              onToggle: _viewModel.toggleQatType,
                            ),
                            const SizedBox(height: AppSpacing.s16),

                            // 2. الأصناف والأجزاء
                            _buildSectionCard(
                              context: context,
                              title: '2. الأصناف والأجزاء المتكررة لديك',
                              subtitle:
                                  'المختار: ${presets.selectedGrades.length} من ${presets.availableGrades.length}',
                              items: presets.availableGrades,
                              selectedItems: presets.selectedGrades,
                              onToggle: _viewModel.toggleQualityGrade,
                            ),
                            const SizedBox(height: AppSpacing.s16),

                            // 3. وحدات البيع
                            _buildSectionCard(
                              context: context,
                              title: '3. وحدات البيع المعتمدة في مفرشك',
                              subtitle:
                                  'المختار: ${presets.selectedUnits.length} من ${presets.availableUnits.length}',
                              items: presets.availableUnits,
                              selectedItems: presets.selectedUnits,
                              onToggle: _viewModel.toggleSaleUnit,
                            ),
                            const SizedBox(height: AppSpacing.s24),
                          ],
                        ),
                      ),

                      // زر الحفظ المتوهج (Glowing Pulse CTA)
                      Container(
                        padding: AppSpacing.p16,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border(top: BorderSide(color: colors.border)),
                        ),
                        child: SafeArea(
                          top: false,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: AppSpacing.radiusFull,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.primary.withValues(
                                        alpha: _pulseAnimation.value,
                                      ),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _viewModel.isSaving ? null : _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppSpacing.radiusFull,
                                  ),
                                ),
                                icon: _viewModel.isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.bolt_rounded, size: 22),
                                label: const Text(
                                  'حفظ الخيارات وتجهيز النشر السريع',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<String> onToggle,
  }) {
    final colors = context.colors;

    return Container(
      padding: AppSpacing.p16,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppSpacing.radius16,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: items.map((item) {
              final isSelected = selectedItems.contains(item);
              return QatfaChoiceChip(
                label: item,
                isSelected: isSelected,
                avatar: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 16,
                  color: isSelected ? Colors.white : colors.textMuted,
                ),
                onSelected: (_) => onToggle(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
