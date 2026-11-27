import 'package:flutter/foundation.dart';

import '../../../../core/constants/qatfa_constants.dart';
import '../../../../data/models/qatfa_models.dart';
import '../../../../data/repositories/qatfa_repositories.dart';

/// حالة نموذج عرض دليل الأسواق (Immutable Markets State)
class MarketsState {
  final List<MarketItem> markets;
  final bool isLoading;
  final String selectedCity;
  final String searchQuery;
  final bool isMapView;
  final String? errorMessage;

  const MarketsState({
    this.markets = const [],
    this.isLoading = false,
    this.selectedCity = QatfaClassificationConstants.allFilter,
    this.searchQuery = '',
    this.isMapView = false,
    this.errorMessage,
  });

  MarketsState copyWith({
    List<MarketItem>? markets,
    bool? isLoading,
    String? selectedCity,
    String? searchQuery,
    bool? isMapView,
    String? errorMessage,
  }) {
    return MarketsState(
      markets: markets ?? this.markets,
      isLoading: isLoading ?? this.isLoading,
      selectedCity: selectedCity ?? this.selectedCity,
      searchQuery: searchQuery ?? this.searchQuery,
      isMapView: isMapView ?? this.isMapView,
      errorMessage: errorMessage,
    );
  }
}

/// نموذج العرض لإدارة عمليات دليل وخريطة الأسواق
class MarketsViewModel extends ChangeNotifier {
  final IMarketsRepository _marketsRepository;

  MarketsState _state = const MarketsState();
  MarketsState get state => _state;

  MarketsViewModel({required this._marketsRepository}) {
    loadMarkets();
  }

  Future<void> loadMarkets() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final items = await _marketsRepository.getMarkets(
        city: _state.selectedCity,
        query: _state.searchQuery,
      );

      _state = _state.copyWith(markets: items, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء تحميل الأسواق: $e',
      );
    }
    notifyListeners();
  }

  void updateCity(String newCity) {
    if (_state.selectedCity == newCity) return;
    _state = _state.copyWith(selectedCity: newCity);
    notifyListeners();
    loadMarkets();
  }

  void updateSearchQuery(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
    loadMarkets();
  }

  void toggleViewMode() {
    _state = _state.copyWith(isMapView: !_state.isMapView);
    notifyListeners();
  }

  Future<List<StallItem>> getStallsForMarket(String marketId) {
    return _marketsRepository.getStallsByMarket(marketId);
  }
}
