import '../../core/constants/qatfa_constants.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../models/qatfa_models.dart';
import '../repositories/qatfa_repositories.dart';
import '../services/mock_qatfa_data.dart';

/// تطبيق مستودع القطفات الفعلي (Isolated Operations / Data Engine)
class DropsRepositoryImpl implements IDropsRepository {
  final List<DropItem> _dataSource;

  DropsRepositoryImpl({List<DropItem>? dataSource})
    : _dataSource = dataSource ?? MockQatfaData.initialDrops;

  @override
  Future<List<DropItem>> getDailyDrops({
    String? city,
    String? marketName,
    String? qatType,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    // محاكاة تأخير الشبكة القصير جداً والواقعي
    await Future.delayed(const Duration(milliseconds: 150));

    Iterable<DropItem> results = _dataSource;

    // فلترة المحافظة
    if (city != null &&
        city.isNotEmpty &&
        city != QatfaClassificationConstants.allFilter) {
      results = results.where(
        (d) => ArabicSearchNormalizer.matches(d.city, city),
      );
    }

    // فلترة السوق
    if (marketName != null &&
        marketName.isNotEmpty &&
        marketName != QatfaClassificationConstants.allFilter) {
      results = results.where(
        (d) => ArabicSearchNormalizer.matches(d.marketName, marketName),
      );
    }

    // فلترة نوع القات
    if (qatType != null &&
        qatType.isNotEmpty &&
        qatType != QatfaClassificationConstants.allFilter) {
      results = results.where(
        (d) => ArabicSearchNormalizer.matches(d.qatType, qatType),
      );
    }

    // فلترة البحث النصي المطبع عربياً
    if (query != null && query.trim().isNotEmpty) {
      results = results.where((d) {
        final matchesTitle = ArabicSearchNormalizer.matches(d.title, query);
        final matchesSeller = ArabicSearchNormalizer.matches(
          d.sellerName,
          query,
        );
        final matchesMarket = ArabicSearchNormalizer.matches(
          d.marketName,
          query,
        );
        final matchesType = ArabicSearchNormalizer.matches(d.qatType, query);
        return matchesTitle || matchesSeller || matchesMarket || matchesType;
      });
    }

    final list = results.skip(offset).take(limit).toList();
    return list;
  }

  @override
  Future<List<DropItem>> searchByBudget({
    required double budget,
    double tolerance = QatfaPerformanceConstants.budgetTolerancePercentage,
    String? city,
    String? marketName,
    String? qatType,
    String? qualityGrade,
    bool availableOnly = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 180));

    double minBudget = budget;
    double maxBudget = budget;

    if (budget > 0) {
      minBudget = budget * (1.0 - tolerance);
      maxBudget = budget * (1.0 + tolerance);
    }

    return _dataSource.where((drop) {
      if (availableOnly && !drop.isAvailable) return false;

      if (city != null &&
          city.isNotEmpty &&
          city != QatfaClassificationConstants.allFilter &&
          !ArabicSearchNormalizer.matches(drop.city, city)) {
        return false;
      }

      if (marketName != null &&
          marketName.isNotEmpty &&
          marketName != QatfaClassificationConstants.allFilter &&
          !ArabicSearchNormalizer.matches(drop.marketName, marketName)) {
        return false;
      }

      if (qatType != null &&
          qatType.isNotEmpty &&
          qatType != QatfaClassificationConstants.allFilter &&
          !ArabicSearchNormalizer.matches(drop.qatType, qatType)) {
        return false;
      }

      if (qualityGrade != null &&
          qualityGrade.isNotEmpty &&
          qualityGrade != QatfaClassificationConstants.allFilter &&
          !ArabicSearchNormalizer.matches(drop.qualityGrade, qualityGrade)) {
        return false;
      }

      if (budget > 0) {
        if (drop.price < minBudget || drop.price > maxBudget) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Future<DropItem?> getDropById(String id) async {
    await Future.delayed(const Duration(milliseconds: 80));
    try {
      return _dataSource.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// تطبيق مستودع الأسواق الشعبية
class MarketsRepositoryImpl implements IMarketsRepository {
  final List<MarketItem> _marketsSource;
  final List<StallItem> _stallsSource;

  MarketsRepositoryImpl({
    List<MarketItem>? marketsSource,
    List<StallItem>? stallsSource,
  }) : _marketsSource = marketsSource ?? MockQatfaData.markets,
       _stallsSource = stallsSource ?? MockQatfaData.stalls;

  @override
  Future<List<MarketItem>> getMarkets({String? city, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 120));

    return _marketsSource.where((market) {
      if (city != null &&
          city.isNotEmpty &&
          city != QatfaClassificationConstants.allFilter &&
          !ArabicSearchNormalizer.matches(market.city, city)) {
        return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final matchesName = ArabicSearchNormalizer.matches(market.name, query);
        final matchesAddress = ArabicSearchNormalizer.matches(
          market.address,
          query,
        );
        if (!matchesName && !matchesAddress) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<StallItem>> getStallsByMarket(String marketId) async {
    await Future.delayed(const Duration(milliseconds: 80));
    return _stallsSource.where((stall) => stall.marketId == marketId).toList();
  }
}
