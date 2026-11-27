import 'package:flutter/foundation.dart';

import '../../../../core/constants/qatfa_constants.dart';
import '../../../../data/models/qatfa_models.dart';
import '../../../../data/repositories/qatfa_repositories.dart';

/// حالة نموذج العرض لموجز القطفات (Immutable Feed State)
class DropsFeedState {
  final List<DropItem> drops;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String selectedCity;
  final String selectedQatType;
  final String searchQuery;
  final String? errorMessage;

  const DropsFeedState({
    this.drops = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.selectedCity = QatfaGeoConstants.defaultCity,
    this.selectedQatType = QatfaClassificationConstants.allFilter,
    this.searchQuery = '',
    this.errorMessage,
  });

  DropsFeedState copyWith({
    List<DropItem>? drops,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? selectedCity,
    String? selectedQatType,
    String? searchQuery,
    String? errorMessage,
  }) {
    return DropsFeedState(
      drops: drops ?? this.drops,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedQatType: selectedQatType ?? this.selectedQatType,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

/// نموذج العرض لإدارة العمليات المتغيرة لموجز القطفات
/// يفصل تماماً العمليات والتحميل والفلترة عن الواجهة المرئية
class DropsFeedViewModel extends ChangeNotifier {
  final IDropsRepository dropsRepository;

  DropsFeedState _state = const DropsFeedState();
  DropsFeedState get state => _state;

  DropsFeedViewModel({
    required this.dropsRepository,
    bool autoLoad = true,
  }) {
    if (autoLoad) {
      loadInitialDrops();
    }
  }

  /// تحميل أولي للقطفات
  Future<void> loadInitialDrops() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final items = await dropsRepository.getDailyDrops(
        city: _state.selectedCity,
        qatType: _state.selectedQatType,
        query: _state.searchQuery,
        limit: QatfaPerformanceConstants.defaultPageLimit,
        offset: 0,
      );

      _state = _state.copyWith(
        drops: items,
        isLoading: false,
        hasMore: items.length >= QatfaPerformanceConstants.defaultPageLimit,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء تحميل القطفات: $e',
      );
    }
    notifyListeners();
  }

  /// تغيير المحافظة
  void updateCity(String newCity) {
    if (_state.selectedCity == newCity) return;
    _state = _state.copyWith(selectedCity: newCity);
    notifyListeners();
    loadInitialDrops();
  }

  /// تغيير فلتر نوع القات
  void updateQatType(String newType) {
    if (_state.selectedQatType == newType) return;
    _state = _state.copyWith(selectedQatType: newType);
    notifyListeners();
    loadInitialDrops();
  }

  /// البحث النصي
  void updateSearchQuery(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
    loadInitialDrops();
  }

  /// تطبيق نتائج الفلترة المخصصة
  void applyCustomResults(List<DropItem> customDrops) {
    _state = _state.copyWith(
      drops: customDrops,
      isLoading: false,
      hasMore: false,
    );
    notifyListeners();
  }

  /// جلب المزيد (Infinite Scroll)
  Future<void> loadMore() async {
    if (_state.isLoadingMore || !_state.hasMore) return;

    _state = _state.copyWith(isLoadingMore: true);
    notifyListeners();

    try {
      final nextItems = await dropsRepository.getDailyDrops(
        city: _state.selectedCity,
        qatType: _state.selectedQatType,
        query: _state.searchQuery,
        limit: QatfaPerformanceConstants.defaultPageLimit,
        offset: _state.drops.length,
      );

      final updatedList = List<DropItem>.from(_state.drops)..addAll(nextItems);

      _state = _state.copyWith(
        drops: updatedList,
        isLoadingMore: false,
        hasMore: nextItems.length >= QatfaPerformanceConstants.defaultPageLimit,
      );
    } catch (_) {
      _state = _state.copyWith(isLoadingMore: false);
    }
    notifyListeners();
  }
}
