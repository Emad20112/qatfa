import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/responsive/text_scaler_boundary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/qatfa_icon_button.dart';
import '../../../../core/widgets/buttons/qatfa_primary_button.dart';
import '../../../../core/widgets/buttons/qatfa_whatsapp_button.dart';
import '../../../../core/widgets/chips/qatfa_choice_chip.dart';
import '../../../../core/widgets/chips/qatfa_status_badge.dart';
import '../../../../core/widgets/dialogs/qatfa_elegant_dialog.dart';
import '../../../../data/repositories/seller_repository.dart';
import '../../../../domain/models/seller_models.dart';
import '../view_models/quick_publish_view_model.dart';
import '../view_models/seller_presets_view_model.dart';
import 'seller_presets_screen.dart';

/// تدفق النشر السريع للمقاوتي (< 30 ثانية، 3 نقرات) + التحكم المزدوج بالتوفر
/// (FR-PROD-01, FR-PROD-05, FR-PROD-07, FR-PROD-10, FR-STORE-06, Flow 3.4 - 3.9)
class QuickPublishScreen extends StatefulWidget {
  final QuickPublishViewModel? viewModel;
  final SellerRepository? repository;
  final String sellerPhoneNumber;
  final String storeName;

  const QuickPublishScreen({
    super.key,
    this.viewModel,
    this.repository,
    this.sellerPhoneNumber = '+967777111222',
    this.storeName = 'مفرش العفيف للقات المختار',
  });

  @override
  State<QuickPublishScreen> createState() => _QuickPublishScreenState();
}

class _QuickPublishScreenState extends State<QuickPublishScreen> {
  late final SellerRepository _repository;
  late final QuickPublishViewModel _viewModel;
  late final bool _ownsViewModel;
  late final TextEditingController _priceController;
  late final TextEditingController _expressController;
  final NumberFormat _priceFormatter = NumberFormat('#,###', 'en_US');

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SellerRepository();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? QuickPublishViewModel(repository: _repository);
    _priceController = TextEditingController();
    _expressController = TextEditingController();
    _viewModel.addListener(_syncTextControllers);
    _viewModel.initialize();
  }

  void _syncTextControllers() {
    if (_priceController.text != _viewModel.priceInput) {
      _priceController.value = TextEditingValue(
        text: _viewModel.priceInput,
        selection: TextSelection.collapsed(offset: _viewModel.priceInput.length),
      );
    }
    if (_expressController.text != _viewModel.expressDescription) {
      _expressController.value = TextEditingValue(
        text: _viewModel.expressDescription,
        selection: TextSelection.collapsed(
          offset: _viewModel.expressDescription.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncTextControllers);
    _priceController.dispose();
    _expressController.dispose();
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _openPresetsScreen() async {
    final presetsVm = SellerPresetsViewModel(repository: _repository);
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SellerPresetsScreen(viewModel: presetsVm),
      ),
    );
    presetsVm.dispose();
    if (mounted) {
      await _viewModel.reloadPresets();
    }
  }

  Future<void> _showQuickAddPresetDialog() async {
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

    final stateKey = GlobalKey<State<StatefulWidget>>();

    Widget buildContent(StateSetter setDialogState) {
      final colors = context.colors;
      final types = splitInput(typeController.text);
      final grades = splitInput(gradeController.text);
      final units = splitInput(unitController.text);
      final total = types.length + grades.length + units.length;

      return Column(
        key: stateKey,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QatfaDialogField(
            key: const Key('quick_add_type_field'),
            title: 'نوع القات',
            hintText: 'مثال: صعدي، مطري، سوتي',
            icon: Icons.eco_rounded,
            controller: typeController,
            onChanged: (_) => setDialogState(() {}),
          ),
          const SizedBox(height: AppSpacing.s10),
          QatfaDialogField(
            key: const Key('quick_add_grade_field'),
            title: 'الصنف / الجودة',
            hintText: 'مثال: رووس، عوارض، قطل',
            icon: Icons.workspace_premium_rounded,
            controller: gradeController,
            onChanged: (_) => setDialogState(() {}),
          ),
          const SizedBox(height: AppSpacing.s10),
          QatfaDialogField(
            key: const Key('quick_add_unit_field'),
            title: 'وحدة البيع',
            hintText: 'مثال: حبة، كيلو، قبضة',
            icon: Icons.scale_rounded,
            controller: unitController,
            optionalBadge: 'اختياري',
            onChanged: (_) => setDialogState(() {}),
          ),
          const SizedBox(height: AppSpacing.s12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: total == 0
                ? Row(
                    key: const ValueKey('empty'),
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 15,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Text(
                          'املأ حقلاً واحداً على الأقل. يمكن إضافة أكثر من اسم بالفصل بفاصلة.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    key: const ValueKey('ready'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: AppSpacing.radiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 15,
                          color: colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.s6),
                        Flexible(
                          child: Text(
                            'جاهز لإضافة $total عنصر إلى قائمتك السريعة',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    }

    final confirmed = await showQatfaElegantDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return QatfaElegantDialog(
              title: 'إضافة عنصر للقائمة السريعة',
              subtitle: 'أضف النوع والصنف والوحدة مرة واحدة، وستظهر فوراً في نافذة النشر السريع.',
              headerIcon: Icons.playlist_add_rounded,
              confirmLabel: 'إضافة فوراً',
              confirmIcon: Icons.bolt_rounded,
              hintText: 'الفصل بفاصلة يضيف عدة عناصر دفعة واحدة.',
              child: buildContent(setDialogState),
              // إغلاق آمن: نغلق الحوار أولاً ثم ننظف الموارد في الإطار التالي
              // لمنع أي تحديث على ويدجت تم التخلص منه (سبب التجمد السابق).
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

    if (confirmed == true) {
      final types = splitInput(typeController.text);
      final grades = splitInput(gradeController.text);
      final units = splitInput(unitController.text);
      typeController.text = '';
      gradeController.text = '';
      unitController.text = '';
      await _viewModel.addCustomPresetItems(
        qatTypes: types,
        qualityGrades: grades,
        saleUnits: units,
      );
    }
  }

  Future<void> _handlePublish() async {
    final success = await _viewModel.publishDrop();
    if (!mounted) return;
    if (success && _viewModel.lastPublishedDrop != null) {
      await _showPublishSuccessSheet(_viewModel.lastPublishedDrop!);
    }
  }

  Future<void> _showPublishSuccessSheet(SellerDropItem drop) async {
    final colors = context.colors;
    final formattedPrice = _priceFormatter.format(drop.priceYer);

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: AppSpacing.p20,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: colors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    'تم نشر قطفتك في السوق بنجاح 🌿',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    '${drop.displayTitle} • $formattedPrice ر.ي / ${drop.unit}',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: colors.agate,
                    ),
                  ),
                  if (drop.media != null) ...[
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'تم ضغط الصورة تلقائياً (${drop.media!.compressedWebpSizeKb}KB WebP)',
                      style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  SizedBox(
                    width: double.infinity,
                    child: QatfaWhatsAppButton(
                      phoneNumber: widget.sellerPhoneNumber,
                      dropTitle: drop.displayTitle,
                      price: '$formattedPrice ر.ي',
                      label: 'سوّق قطفتك على الواتساب بضغطة زر',
                      height: 48,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('إغلاق ومتابعة إدارة المفرش'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleToggleProduct(SellerDropItem drop) async {
    final updated = await _viewModel.toggleProductAvailability(drop.id);
    if (!mounted || updated == null) return;

    if (!updated.isAvailable) {
      await showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
        ),
        builder: (sheetContext) {
          final colors = context.colors;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: AppSpacing.p20,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: colors.statusPending),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Text(
                            'تم إخفاء "${updated.displayTitle}" تلقائياً',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'تم إخفاء القطفة من نتائج البحث لتفادي اتصالات الزبائن على بضاعة نافدة.',
                      style: TextStyle(fontSize: 13, color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    SizedBox(
                      width: double.infinity,
                      child: QatfaPrimaryButton(
                        label: 'إعادة تفعيل العرض للزبائن',
                        leadingIcon: const Icon(Icons.refresh_rounded, size: 18),
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          await _viewModel.toggleProductAvailability(updated.id);
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('تأكيد إخفاء المنتج من السوق'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
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
                icon: Icons.close_rounded,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                iconColor: Colors.white,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            title: const Text(
              'نشر قطفة اليوم السريعة',
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
                  onPressed: _openPresetsScreen,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.radiusFull,
                    ),
                  ),
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text(
                    'القوائم المسبقة',
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
                  child: ListView(
                    padding: AppSpacing.p16,
                    children: [
                      // 1. المفتاح الرئيسي للمتجر (Master Store Toggle)
                      _buildMasterStoreToggleCard(colors),
                      const SizedBox(height: AppSpacing.s12),

                      // شريط التبديل بين النشر السريع بالقوائم والإعلان السريع اليومي + زر الإضافة الفورية
                      _buildTopActionsRow(colors),
                      const SizedBox(height: AppSpacing.s14),

                      // 2. الكاميرا الحية والضغط التلقائي بصيغة WebP
                      _buildLiveCameraCard(colors),
                      const SizedBox(height: AppSpacing.s14),

                      // 3. إما القوائم المجهزة مسبقاً أو نموذج الإعلان السريع
                      if (_viewModel.isExpressMode)
                        _buildExpressAdFields(colors)
                      else
                        _buildPresetSelectionCard(colors, presets),
                      const SizedBox(height: AppSpacing.s14),

                      // 4. حقل السعر الكبير بنقرة واحدة + لوحة الأرقام المريحة
                      _buildGiantPriceSection(colors),
                      const SizedBox(height: AppSpacing.s14),

                      // 5. حالة التوفر المبدئية وزر النشر الفوري
                      _buildAvailabilityAndPublishSection(colors),

                      if (_viewModel.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.s12),
                        Container(
                          padding: AppSpacing.p12,
                          decoration: BoxDecoration(
                            color: colors.statusSoldOut.withValues(alpha: 0.12),
                            borderRadius: AppSpacing.radius12,
                            border: Border.all(
                              color: colors.statusSoldOut.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: colors.statusSoldOut),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: Text(
                                  _viewModel.errorMessage!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: colors.statusSoldOut,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s24),

                      // 6. قائمة عروضي النشطة اليوم مع المفتاح المستقل لكل منتج
                      _buildPerProductControlList(colors),
                      const SizedBox(height: AppSpacing.s32),
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

  Widget _buildMasterStoreToggleCard(QatfaColors colors) {
    final isOpen = _viewModel.isStoreOpen;
    final statusColor = isOpen ? colors.statusConfirmed : colors.statusSoldOut;

    return Container(
      padding: AppSpacing.p12,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: AppSpacing.radius16,
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.16),
              borderRadius: AppSpacing.radius12,
            ),
            child: Icon(
              isOpen ? Icons.storefront_rounded : Icons.store_mall_directory_outlined,
              color: statusColor,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen
                      ? 'متجري متاح ويستقبل الطلبات'
                      : 'متجري مغلق مؤقتاً',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  isOpen
                      ? '${widget.storeName} • ظاهر على خريطة السوق'
                      : 'تم إخفاء المتجر وإيقاف الاستفسارات مؤقتاً',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            key: const Key('master_store_toggle'),
            value: isOpen,
            activeTrackColor: colors.statusConfirmed,
            onChanged: (_) => _viewModel.toggleMasterStoreOpen(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActionsRow(QatfaColors colors) {
    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: AppSpacing.s8,
          children: [
            QatfaChoiceChip(
              label: 'نشر بالقوائم المسبقة',
              isSelected: !_viewModel.isExpressMode,
              onSelected: (_) => _viewModel.setExpressMode(false),
            ),
            QatfaChoiceChip(
              label: 'إعلان سريع اليوم ⚡',
              isSelected: _viewModel.isExpressMode,
              onSelected: (_) => _viewModel.setExpressMode(true),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: _showQuickAddPresetDialog,
          style: TextButton.styleFrom(
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.radiusFull,
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 17),
          label: const Text(
            'إضافة نوع / صنف',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveCameraCard(QatfaColors colors) {
    final media = _viewModel.capturedMedia;

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
              Icon(Icons.camera_alt_rounded, size: 18, color: colors.primary),
              const SizedBox(width: AppSpacing.s6),
              Expanded(
                child: Text(
                  '1. صورة القات الحية (ضغط تلقائي WebP)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              QatfaStatusBadge(
                label: media != null
                    ? 'WebP • ${media.compressedWebpSizeKb}KB'
                    : 'كاميرا حية',
                statusType:
                    media != null ? QatfaStatusType.fresh : QatfaStatusType.active,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          if (media == null)
            InkWell(
              key: const Key('live_camera_capture_button'),
              onTap: _viewModel.isCapturingCamera
                  ? null
                  : _viewModel.captureLivePhoto,
              borderRadius: AppSpacing.radius16,
              child: Container(
                height: 126,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E3813), Color(0xFF1B5E20)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: AppSpacing.radius16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_viewModel.isCapturingCamera)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.s8),
                    const Text(
                      'اضغط لالتقاط صورة القطفة مباشرة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'يتم الضغط فوراً إلى WebP أقل من 100KB لتوفير الباقة',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: AppSpacing.p12,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: AppSpacing.radius16,
                border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreenDark,
                      borderRadius: AppSpacing.radius12,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Color(0xFF4ADE80),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تم التقاط وضغط الصورة بنجاح',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          '${media.widthPx}×${media.heightPx} • تم تقليص الحجم ${media.compressionRatio.toStringAsFixed(0)}% (${media.compressedWebpSizeKb}KB WebP)',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'إعادة التقاط',
                    onPressed: _viewModel.captureLivePhoto,
                    icon: Icon(Icons.refresh_rounded, color: colors.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpressAdFields(QatfaColors colors) {
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
              Icon(Icons.bolt_rounded, color: colors.agate, size: 20),
              const SizedBox(width: AppSpacing.s6),
              Expanded(
                child: Text(
                  '2. تفاصيل الإعلان السريع اليومي (إعلان واحد يومياً)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s10),
          TextField(
            controller: _expressController,
            maxLines: 3,
            onChanged: _viewModel.updateExpressDescription,
            decoration: InputDecoration(
              hintText:
                  'مثال: قات حوشب طازج قطفة الفجر نظيف وممتاز، متواجدين في سوق شميلة...',
              border: OutlineInputBorder(borderRadius: AppSpacing.radius12),
              enabledBorder:
                  OutlineInputBorder(borderRadius: AppSpacing.radius12),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.radius12,
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelectionCard(QatfaColors colors, SellerPresets presets) {
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
                  '2. اختر من قوائمك المجهزة مسبقاً',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openPresetsScreen,
                child: const Text('تعديل القوائم'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'النوع:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: presets.selectedTypes
                .map(
                  (type) => QatfaChoiceChip(
                    label: type,
                    isSelected: _viewModel.selectedType == type,
                    onSelected: (_) => _viewModel.selectType(type),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'الصنف / الجودة:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: presets.selectedGrades
                .map(
                  (grade) => QatfaChoiceChip(
                    label: grade,
                    isSelected: _viewModel.selectedGrade == grade,
                    onSelected: (_) => _viewModel.selectGrade(grade),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'وحدة البيع:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: presets.selectedUnits
                .map(
                  (unit) => QatfaChoiceChip(
                    label: unit,
                    isSelected: _viewModel.selectedUnit == unit,
                    onSelected: (_) => _viewModel.selectUnit(unit),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGiantPriceSection(QatfaColors colors) {
    final parsed = int.tryParse(_viewModel.priceInput) ?? 0;
    final formattedDisplay =
        parsed > 0 ? '${_priceFormatter.format(parsed)} ر.ي' : '0 ر.ي';

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
              Icon(Icons.payments_outlined, color: colors.agate, size: 20),
              const SizedBox(width: AppSpacing.s6),
              Expanded(
                child: Text(
                  '3. السعر بنقرة واحدة (ريال يمني)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                formattedDisplay,
                style: AppTypography.priceTagLarge(color: colors.agate),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),

          // حقل إدخال رقمي كبير واضح
          TextField(
            key: const Key('quick_price_input'),
            controller: _priceController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTypography.priceTagLarge(color: colors.textPrimary).copyWith(
              fontSize: 26,
            ),
            onChanged: _viewModel.setPrice,
            decoration: InputDecoration(
              hintText: 'أدخل السعر مثال: 12000',
              suffixText: 'ر.ي',
              filled: true,
              fillColor: colors.surfaceElevated,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s16,
              ),
              border: OutlineInputBorder(
                borderRadius: AppSpacing.radius16,
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppSpacing.radius16,
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.radius16,
                borderSide: BorderSide(color: colors.agate, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s10),

          // أسعار جاهزة سريعة بنقرة إبهام واحدة
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: ['5000', '8000', '10000', '12000', '15000', '20000']
                .map(
                  (presetPrice) => QatfaChoiceChip(
                    label: '${_priceFormatter.format(int.parse(presetPrice))} ر.ي',
                    isSelected: _viewModel.priceInput == presetPrice,
                    onSelected: (_) => _viewModel.setPrice(presetPrice),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.s12),

          // لوحة أرقام عملاقة مريحة للعمل في السوق المزدحم
          _buildComfortKeypad(colors),
        ],
      ),
    );
  }

  Widget _buildComfortKeypad(QatfaColors colors) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['000', '0', '⌫'],
    ];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s6),
            child: Row(
              children: row.map((keyLabel) {
                final isBackspace = keyLabel == '⌫';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Material(
                      color: isBackspace
                          ? colors.statusSoldOut.withValues(alpha: 0.1)
                          : colors.surfaceElevated,
                      borderRadius: AppSpacing.radius12,
                      child: InkWell(
                        borderRadius: AppSpacing.radius12,
                        onTap: () {
                          if (isBackspace) {
                            _viewModel.backspacePrice();
                          } else if (keyLabel == '000') {
                            _viewModel.appendDigit('0');
                            _viewModel.appendDigit('0');
                            _viewModel.appendDigit('0');
                          } else {
                            _viewModel.appendDigit(keyLabel);
                          }
                        },
                        onLongPress: isBackspace ? _viewModel.clearPrice : null,
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: isBackspace
                                ? Icon(
                                    Icons.backspace_outlined,
                                    color: colors.statusSoldOut,
                                    size: 20,
                                  )
                                : Text(
                                    keyLabel,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvailabilityAndPublishSection(QatfaColors colors) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AvailabilityOptionTile(
                label: 'متوفر في مفرشي',
                isSelected: _viewModel.isDropAvailable,
                activeColor: colors.statusFresh,
                icon: Icons.check_circle_rounded,
                onTap: () => _viewModel.setDropAvailable(true),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: _AvailabilityOptionTile(
                label: 'نفدت الكمية',
                isSelected: !_viewModel.isDropAvailable,
                activeColor: colors.statusSoldOut,
                icon: Icons.cancel_rounded,
                onTap: () => _viewModel.setDropAvailable(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s14),
        SizedBox(
          width: double.infinity,
          child: QatfaPrimaryButton(
            key: const Key('publish_drop_button'),
            label: _viewModel.isExpressMode
                ? 'نشر الإعلان السريع الآن ⚡'
                : 'انشر القطفة الآن 🌿',
            height: 54,
            isLoading: _viewModel.isPublishing,
            leadingIcon: const Icon(Icons.rocket_launch_rounded, size: 20),
            onPressed: _handlePublish,
          ),
        ),
      ],
    );
  }

  Widget _buildPerProductControlList(QatfaColors colors) {
    final drops = _viewModel.drops;

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
              Icon(Icons.inventory_2_outlined, color: colors.primary, size: 20),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  'عروضي النشطة اليوم (تحكم مستقل بكل منتج)',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${drops.length} عروض',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          for (int i = 0; i < drops.length; i++) ...[
            _SellerDropAvailabilityTile(
              drop: drops[i],
              formattedPrice: _priceFormatter.format(drops[i].priceYer),
              onToggle: () => _handleToggleProduct(drops[i]),
            ),
            if (i < drops.length - 1) const Divider(height: AppSpacing.s16),
          ],
        ],
      ),
    );
  }
}

class _AvailabilityOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final IconData icon;
  final VoidCallback onTap;

  const _AvailabilityOptionTile({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: isSelected ? activeColor.withValues(alpha: 0.14) : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.radius16,
        side: BorderSide(
          color: isSelected ? activeColor : colors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: AppSpacing.radius16,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? activeColor : colors.textMuted),
              const SizedBox(width: AppSpacing.s6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? activeColor : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerDropAvailabilityTile extends StatelessWidget {
  final SellerDropItem drop;
  final String formattedPrice;
  final VoidCallback onToggle;

  const _SellerDropAvailabilityTile({
    required this.drop,
    required this.formattedPrice,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppSpacing.radius12,
          ),
          child: Icon(
            Icons.eco_rounded,
            color: drop.isAvailable ? colors.primary : colors.textMuted,
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                drop.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Row(
                children: [
                  Text(
                    '$formattedPrice ر.ي / ${drop.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.agate,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  QatfaStatusBadge(
                    label: drop.isAvailable ? 'متوفر' : 'نفدت الكمية',
                    statusType: drop.isAvailable
                        ? QatfaStatusType.fresh
                        : QatfaStatusType.soldOut,
                  ),
                ],
              ),
            ],
          ),
        ),
        Switch.adaptive(
          key: Key('product_toggle_${drop.id}'),
          value: drop.isAvailable,
          activeTrackColor: colors.statusFresh,
          onChanged: (_) => onToggle(),
        ),
      ],
    );
  }
}
