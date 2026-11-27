import 'package:flutter/material.dart';

import '../../../../core/constants/qatfa_constants.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/drop_grid_card.dart';
import '../../../../core/widgets/chips/qatfa_choice_chip.dart';
import '../../../../core/widgets/feedback/qatfa_shimmer_box.dart';
import '../../../../core/widgets/feedback/qatfa_trust_badge_bar.dart';
import '../../../../core/widgets/inputs/qatfa_search_field.dart';
import '../../../../core/widgets/navigation/qatfa_app_bar_header.dart';
import '../../../../data/models/qatfa_models.dart';
import '../../../../data/repositories/qatfa_repositories_impl.dart';
import '../../drop_detail/views/drop_detail_screen.dart';
import '../../search/views/smart_budget_search_modal.dart';
import '../view_models/drops_feed_view_model.dart';
import '../widgets/hero_drop_banner.dart';

/// الشاشة الرئيسية وموجز قطفات اليوم المتجددة (HomeScreen / DropsFeedView)
/// تعتمد على نمط MVVM النظيف حيث تفصل العمليات المتغيرة في DropsFeedViewModel
class HomeScreen extends StatefulWidget {
  final ValueChanged<DropItem>? onDropSelected;
  final VoidCallback? onOpenMarkets;
  final DropsFeedViewModel? viewModel;

  const HomeScreen({
    super.key,
    this.onDropSelected,
    this.onOpenMarkets,
    this.viewModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DropsFeedViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        DropsFeedViewModel(dropsRepository: DropsRepositoryImpl());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  /// مراقبة موضع التمرير لتنفيذ التحميل اللانهائي عند بلوغ 85%
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >=
        (maxScroll * QatfaPerformanceConstants.paginationScrollThreshold)) {
      _viewModel.loadMore();
    }
  }

  /// فتح نافذة الفلترة والبحث الذكي بالميزانية
  void _openSmartBudgetSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SmartBudgetSearchModal(
        initialCity: _viewModel.state.selectedCity,
        onApplyFilter: (results, budgetInfo) {
          _viewModel.applyCustomResults(results);
        },
      ),
    );
  }

  /// نافذة اختيار المحافظة السريعة
  void _openCitySelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: AppSpacing.p16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'اختر المحافظة أو المدينة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: QatfaGeoConstants.supportedCities.map((city) {
                    final isSel = city == _viewModel.state.selectedCity;
                    return QatfaChoiceChip(
                      label: city,
                      isSelected: isSel,
                      onSelected: (_) {
                        _viewModel.updateCity(city);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToDropDetail(DropItem drop) {
    if (widget.onDropSelected != null) {
      widget.onDropSelected!(drop);
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => DropDetailScreen(drop: drop)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;

        return Scaffold(
          backgroundColor: colors.surfaceElevated,
          body: Column(
            children: [
              // الترويسة التراثية العلوية
              QatfaAppBarHeader(
                locationText: state.selectedCity,
                notificationCount: 2,
                onLocationTap: _openCitySelector,
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('وصلت للتو قطفة أرحبي جديدة في سوق الملح!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              // المحتوى القابل للتمرير والسحب للتحديث
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _viewModel.loadInitialDrops,
                  color: colors.primary,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // شريط البحث المدمج والفلترة بالميزانية
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s16,
                            AppSpacing.s12,
                            AppSpacing.s16,
                            AppSpacing.s8,
                          ),
                          child: QatfaSearchField(
                            controller: _searchController,
                            hintText: 'ابحث عن نوع القات (همداني، أرحبي، شامي...) أو المقاوتي...',
                            onChanged: _viewModel.updateSearchQuery,
                            onFilterTap: _openSmartBudgetSearch,
                          ),
                        ),
                      ),

                      // شريط رقاقات أنواع القات القابل للتمرير الأفقي
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: AppSpacing.ph16,
                            itemCount:
                                QatfaClassificationConstants.qatTypes.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: AppSpacing.s8),
                            itemBuilder: (context, index) {
                              final type =
                                  QatfaClassificationConstants.qatTypes[index];
                              final isSelected = type == state.selectedQatType;
                              return Center(
                                child: QatfaChoiceChip(
                                  label: type,
                                  isSelected: isSelected,
                                  onSelected: (_) =>
                                      _viewModel.updateQatType(type),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // بانر العرض المميز البطل (Hero Drop Banner)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s16,
                            AppSpacing.s12,
                            AppSpacing.s16,
                            AppSpacing.s12,
                          ),
                          child: HeroDropBanner(
                            onActionTap: () {
                              if (state.drops.isNotEmpty) {
                                _navigateToDropDetail(state.drops.first);
                              }
                            },
                          ),
                        ),
                      ),

                      // شريط ركائز الثقة
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16,
                          ),
                          child: QatfaTrustBadgeBar(),
                        ),
                      ),

                      // عنوان القسم وشارة التحديث المباشر
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s16,
                            AppSpacing.s16,
                            AppSpacing.s16,
                            AppSpacing.s8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'قطفات اليوم المتجددة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${state.drops.length} عرض متوفر',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // محتوى الشبكة أو التحميل الشبحي
                      if (state.isLoading)
                        SliverPadding(
                          padding: AppSpacing.p16,
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.62,
                                  crossAxisSpacing: AppSpacing.s12,
                                  mainAxisSpacing: AppSpacing.s12,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => const QatfaShimmerBox(),
                              childCount: 4,
                            ),
                          ),
                        )
                      else if (state.drops.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                              horizontal: 20,
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 52,
                                    color: colors.textMuted,
                                  ),
                                  const SizedBox(height: AppSpacing.s12),
                                  Text(
                                    'لا توجد قطفات مطابقة لبحثك في ${state.selectedCity} حالياً',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s16,
                            AppSpacing.s4,
                            AppSpacing.s16,
                            AppSpacing.s16,
                          ),
                          sliver: ResponsiveLayout(
                            mobile: (context) => SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.60,
                                    crossAxisSpacing: AppSpacing.s12,
                                    mainAxisSpacing: AppSpacing.s12,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final drop = state.drops[index];
                                return DropGridCard(
                                  title: drop.title,
                                  sellerName: drop.sellerName,
                                  price: '${drop.price}',
                                  oldPrice: drop.oldPrice != null
                                      ? '${drop.oldPrice}'
                                      : null,
                                  imageUrl: drop.imageUrl,
                                  phoneNumber: drop.sellerPhone,
                                  isFresh: drop.isFresh,
                                  onTap: () => _navigateToDropDetail(drop),
                                );
                              }, childCount: state.drops.length),
                            ),
                            tablet: (context) => SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.65,
                                    crossAxisSpacing: AppSpacing.s16,
                                    mainAxisSpacing: AppSpacing.s16,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final drop = state.drops[index];
                                return DropGridCard(
                                  title: drop.title,
                                  sellerName: drop.sellerName,
                                  price: '${drop.price}',
                                  oldPrice: drop.oldPrice != null
                                      ? '${drop.oldPrice}'
                                      : null,
                                  imageUrl: drop.imageUrl,
                                  phoneNumber: drop.sellerPhone,
                                  isFresh: drop.isFresh,
                                  onTap: () => _navigateToDropDetail(drop),
                                );
                              }, childCount: state.drops.length),
                            ),
                          ),
                        ),

                      // مؤشر التحميل الإضافي في الأسفل (Pagination Loader)
                      if (state.isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
