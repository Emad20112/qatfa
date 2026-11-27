import '../models/qatfa_models.dart';

/// عقد مستودع القطفات اليومية (Drops Repository Contract)
abstract class IDropsRepository {
  /// جلب موجز القطفات اليومية اللحظية مع التصفية
  Future<List<DropItem>> getDailyDrops({
    String? city,
    String? marketName,
    String? qatType,
    String? query,
    int limit = 20,
    int offset = 0,
  });

  /// البحث الذكي بحدود الميزانية المالية
  Future<List<DropItem>> searchByBudget({
    required double budget,
    double tolerance = 0.10,
    String? city,
    String? marketName,
    String? qatType,
    String? qualityGrade,
    bool availableOnly = true,
  });

  /// جلب تفاصيل قطفة محددة بالمعرف
  Future<DropItem?> getDropById(String id);
}

/// عقد مستودع الأسواق الشعبية والمفارش (Markets Repository Contract)
abstract class IMarketsRepository {
  /// جلب دليل الأسواق الشعبية بحسب المحافظة
  Future<List<MarketItem>> getMarkets({String? city, String? query});

  /// جلب مفارش السوق المحدد على الخريطة
  Future<List<StallItem>> getStallsByMarket(String marketId);
}
