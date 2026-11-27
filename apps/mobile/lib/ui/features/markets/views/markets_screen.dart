import 'package:flutter/material.dart';

import '../../../../core/constants/qatfa_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/market_summary_card.dart';
import '../../../../core/widgets/chips/qatfa_choice_chip.dart';
import '../../../../core/widgets/inputs/qatfa_search_field.dart';
import '../../../../data/models/qatfa_models.dart';
import '../../../../data/repositories/qatfa_repositories_impl.dart';
import '../view_models/markets_view_model.dart';
import 'market_map_view.dart';

/// دليل الأسواق والخريطة التفاعلية (MarketsScreen)
/// يفصل العمليات المتغيرة في MarketsViewModel عن البنية المرئية
class MarketsScreen extends StatefulWidget {
  final ValueChanged<MarketItem>? onMarketSelected;
  final MarketsViewModel? viewModel;

  const MarketsScreen({super.key, this.onMarketSelected, this.viewModel});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  late final MarketsViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        MarketsViewModel(marketsRepository: MarketsRepositoryImpl());
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  void _openMarketMap(MarketItem market) {
    if (widget.onMarketSelected != null) {
      widget.onMarketSelected!(market);
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => MarketMapView(market: market)));
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
          appBar: AppBar(
            title: Text(
              'دليل أسواق القات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            backgroundColor: colors.surface,
            elevation: 0,
            actions: [
              // زر التبديل بين القائمة والخريطة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                child: TextButton.icon(
                  onPressed: _viewModel.toggleViewMode,
                  icon: Icon(
                    state.isMapView
                        ? Icons.list_alt_rounded
                        : Icons.map_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                  label: Text(
                    state.isMapView ? 'عرض القائمة' : 'وضع الخريطة',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // حقل البحث
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s12,
                  AppSpacing.s16,
                  AppSpacing.s8,
                ),
                child: QatfaSearchField(
                  controller: _searchController,
                  hintText: 'ابحث عن السوق أو المحافظة...',
                  onChanged: _viewModel.updateSearchQuery,
                ),
              ),

              // رقاقات المحافظات في الأعلى
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.ph16,
                  itemCount: QatfaGeoConstants.marketsFilterOptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.s8),
                  itemBuilder: (context, index) {
                    final city = QatfaGeoConstants.marketsFilterOptions[index];
                    final isSelected = city == state.selectedCity;
                    return Center(
                      child: QatfaChoiceChip(
                        label: city,
                        isSelected: isSelected,
                        onSelected: (_) => _viewModel.updateCity(city),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s8),

              // المحتوى: إما قائمة الأسواق أو الخريطة
              Expanded(
                child: state.isMapView
                    ? _buildEmbeddedMapView(colors, state.markets)
                    : _buildMarketsListView(colors, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarketsListView(QatfaColors colors, MarketsState state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    final markets = state.markets;

    if (markets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 54, color: colors.textMuted),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'لا توجد أسواق مسجلة تطابق بحثك حالياً',
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: AppSpacing.p16,
      itemCount: markets.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final market = markets[index];
        return MarketSummaryCard(
          marketName: market.name,
          location: '${market.city} - ${market.address}',
          rating: '${market.rating}',
          activeSellersCount: '${market.activeSellersCount}',
          workingHours: market.workingHours,
          imageUrl: market.imageUrl,
          onTap: () => _openMarketMap(market),
        );
      },
    );
  }

  Widget _buildEmbeddedMapView(QatfaColors colors, List<MarketItem> markets) {
    final targetMarket = markets.isNotEmpty ? markets.first : null;

    if (targetMarket == null) {
      return Center(
        child: Text(
          'لا يتوفر سوق محدد لعرض الخريطة',
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }

    return MarketMapView(market: targetMarket);
  }
}
