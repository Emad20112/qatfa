import 'package:flutter/material.dart';

import '../../../../core/constants/qatfa_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/qatfa_primary_button.dart';
import '../../../../core/widgets/chips/qatfa_choice_chip.dart';
import '../../../../data/models/qatfa_models.dart';
import '../../../../data/repositories/qatfa_repositories.dart';
import '../../../../data/repositories/qatfa_repositories_impl.dart';

/// معلومات نتيجة البحث بالميزانية
class BudgetSearchSummary {
  final double targetBudget;
  final double minBudget;
  final double maxBudget;
  final bool isFlexibleRange;
  final String selectedMarket;
  final String selectedType;
  final String selectedGrade;

  const BudgetSearchSummary({
    required this.targetBudget,
    required this.minBudget,
    required this.maxBudget,
    required this.isFlexibleRange,
    required this.selectedMarket,
    required this.selectedType,
    required this.selectedGrade,
  });
}

/// نافذة البحث الذكي بالميزانية المتوفرة والفلترة المتقدمة (SmartBudgetSearchModal)
/// تفصل العمليات الحسابية ومطابقة الميزانية عبر IDropsRepository
class SmartBudgetSearchModal extends StatefulWidget {
  final String initialCity;
  final IDropsRepository? dropsRepository;
  final void Function(List<DropItem> results, BudgetSearchSummary summary)?
  onApplyFilter;

  const SmartBudgetSearchModal({
    super.key,
    this.initialCity = QatfaGeoConstants.defaultCity,
    this.dropsRepository,
    this.onApplyFilter,
  });

  @override
  State<SmartBudgetSearchModal> createState() => _SmartBudgetSearchModalState();
}

class _SmartBudgetSearchModalState extends State<SmartBudgetSearchModal> {
  late final IDropsRepository _dropsRepository;
  final TextEditingController _budgetController = TextEditingController(
    text: '8000',
  );

  bool _isFlexibleRange = true; // نطاق مرن ±10%
  String _selectedMarket = QatfaClassificationConstants.allFilter;
  String _selectedQatType = QatfaClassificationConstants.allFilter;
  String _selectedQualityGrade = QatfaClassificationConstants.allFilter;
  bool _availableOnly = true;
  bool _isSearching = false;

  final List<String> _marketsInCity = [
    QatfaClassificationConstants.allFilter,
    'سوق الملح',
    'سوق علي محسن',
    'سوق شميلة',
    'سوق نقم',
    'سوق الشيخ عثمان',
  ];

  @override
  void initState() {
    super.initState();
    _dropsRepository = widget.dropsRepository ?? DropsRepositoryImpl();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  /// احتساب ومطابقة العروض بحسب الميزانية والمعايير عبر مستودع البيانات
  Future<void> _applyBudgetSearch() async {
    final rawText = _budgetController.text.replaceAll(',', '').trim();
    final double budget = double.tryParse(rawText) ?? 0;

    setState(() => _isSearching = true);

    final tolerance = _isFlexibleRange
        ? QatfaPerformanceConstants.budgetTolerancePercentage
        : 0.0;
    final double minBudget = budget > 0 ? budget * (1.0 - tolerance) : 0;
    final double maxBudget = budget > 0 ? budget * (1.0 + tolerance) : 0;

    final results = await _dropsRepository.searchByBudget(
      budget: budget,
      tolerance: tolerance,
      city: widget.initialCity,
      marketName: _selectedMarket,
      qatType: _selectedQatType,
      qualityGrade: _selectedQualityGrade,
      availableOnly: _availableOnly,
    );

    if (!mounted) return;
    setState(() => _isSearching = false);

    final summary = BudgetSearchSummary(
      targetBudget: budget,
      minBudget: minBudget,
      maxBudget: maxBudget,
      isFlexibleRange: _isFlexibleRange,
      selectedMarket: _selectedMarket,
      selectedType: _selectedQatType,
      selectedGrade: _selectedQualityGrade,
    );

    widget.onApplyFilter?.call(results, summary);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // حساب النطاق المرن للعرض المباشر
    final rawText = _budgetController.text.replaceAll(',', '').trim();
    final double enteredBudget = double.tryParse(rawText) ?? 0;
    final int minCalculated =
        (enteredBudget *
                (1.0 - QatfaPerformanceConstants.budgetTolerancePercentage))
            .round();
    final int maxCalculated =
        (enteredBudget *
                (1.0 + QatfaPerformanceConstants.budgetTolerancePercentage))
            .round();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s12,
            AppSpacing.s16,
            bottomInset + AppSpacing.s16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          // مقبض السحب العلوي (Drag Handle)
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: AppSpacing.radiusFull,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),

          // ترويسة النافذة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune_rounded, color: colors.primary, size: 22),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'البحث الذكي بالميزانية والفلترة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. حقل الميزانية المتوفرة
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: Color(0xFFE65100),
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        'كم المبلغ المتوفر في جيبك الآن؟',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: AppSpacing.radius16,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE65100),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'مثال: 8000',
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        Text(
                          'ريال يمني',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  // مفتاح نطاق البحث المرن (±10%)
                  InkWell(
                    onTap: () {
                      setState(() => _isFlexibleRange = !_isFlexibleRange);
                    },
                    borderRadius: AppSpacing.radius12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isFlexibleRange
                            ? colors.primaryContainer.withValues(alpha: 0.5)
                            : Colors.transparent,
                        borderRadius: AppSpacing.radius12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isFlexibleRange
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 20,
                            color: _isFlexibleRange
                                ? colors.primary
                                : colors.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نطاق بحث مرن (±10% حول المبلغ)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                if (enteredBudget > 0 && _isFlexibleRange)
                                  Text(
                                    'يبحث بين $minCalculated و $maxCalculated ريال',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 2. محدد نطاق السوق المختار
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        'نطاق السوق الشعبي المختار',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: _marketsInCity.map((market) {
                      final isSel = market == _selectedMarket;
                      return QatfaChoiceChip(
                        label: market,
                        isSelected: isSel,
                        onSelected: (_) {
                          setState(() => _selectedMarket = market);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 3. رقاقات أنواع القات
                  Row(
                    children: [
                      Icon(Icons.eco_outlined, size: 18, color: colors.primary),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        'نوع القات المطلوب',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: QatfaClassificationConstants.qatTypes.map((type) {
                      final isSel = type == _selectedQatType;
                      return QatfaChoiceChip(
                        label: type,
                        isSelected: isSel,
                        onSelected: (_) {
                          setState(() => _selectedQatType = type);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 4. رقاقات الصنف والجودة
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        'الصنف والجودة',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children:
                        [
                          QatfaClassificationConstants.allFilter,
                          ...QatfaClassificationConstants.qualityGrades,
                        ].map((grade) {
                          final isSel = grade == _selectedQualityGrade;
                          return QatfaChoiceChip(
                            label: grade,
                            isSelected: isSel,
                            onSelected: (_) {
                              setState(() => _selectedQualityGrade = grade);
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.s16),

          // 5. حالة التوفر
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'المتوفر في السوق الآن فقط',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            subtitle: Text(
              'استبعاد العروض المنتهية أو المغلقة لتوفير المشوار',
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
              ),
            ),
            value: _availableOnly,
            activeThumbColor: colors.primary,
            activeTrackColor: colors.primary.withValues(alpha: 0.3),
            onChanged: (val) {
              setState(() => _availableOnly = val);
            },
          ),
                ],
              ),
            ),
          ),

          // زر التطبيق والبحث
          QatfaPrimaryButton(
            label: 'إظهار القطفات والمقاوتة المناسبين لميزانيتي',
            height: 50,
            isLoading: _isSearching,
            leadingIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _applyBudgetSearch,
          ),
        ],
      ),
    ),
  ),
);
  }
}
