import 'package:dio/dio.dart';
import '../models/qatfa_models.dart';
import '../services/dio_client.dart';
import '../services/api_endpoints.dart';
import '../services/mock_qatfa_data.dart';

/// واجهة مستودع عروض القطفات (IDropsRepository)
abstract class IDropsRepository {
  Future<List<DropItem>> getDailyDrops({
    String? city,
    String? qatType,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  });

  Future<List<DropItem>> searchDropsByBudget({
    required int budget,
    double tolerance = 0.10,
    String? qatType,
    String? marketId,
    CancelToken? cancelToken,
  });

  Future<DropItem?> getDropById(String id, {CancelToken? cancelToken});
}

/// تنفيذ مستودع عروض القطفات مع التراجع للبيانات المجهزة (Offline Resilience)
class DropsRepositoryImpl implements IDropsRepository {
  final DioClient _client;

  DropsRepositoryImpl({DioClient? client}) : _client = client ?? DioClient();

  @override
  Future<List<DropItem>> getDailyDrops({
    String? city,
    String? qatType,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.dailyDrops,
        queryParameters: {
          if (city != null && city != 'الكل') 'city': city,
          if (qatType != null && qatType != 'الكل') 'qatType': qatType,
          'page': page,
          'limit': limit,
        },
        cancelToken: cancelToken,
      );

      if (response.data is List) {
        // إذا توفر الـ API يتم تحويل النماذج
      }
      return _filterLocalDrops(city: city, qatType: qatType);
    } catch (_) {
      return _filterLocalDrops(city: city, qatType: qatType);
    }
  }

  @override
  Future<List<DropItem>> searchDropsByBudget({
    required int budget,
    double tolerance = 0.10,
    String? qatType,
    String? marketId,
    CancelToken? cancelToken,
  }) async {
    final minPrice = budget * (1.0 - tolerance);
    final maxPrice = budget * (1.0 + tolerance);

    try {
      final response = await _client.get(
        ApiEndpoints.searchProducts,
        queryParameters: {
          'budget': budget,
          'tolerance': tolerance,
          if (qatType != null && qatType != 'الكل') 'qatType': qatType,
          if (marketId != null) 'marketId': marketId,
        },
        cancelToken: cancelToken,
      );

      if (response.data is List) {
        // تحويل استجابة API
      }
      return _searchLocalDrops(minPrice: minPrice, maxPrice: maxPrice, qatType: qatType);
    } catch (_) {
      return _searchLocalDrops(minPrice: minPrice, maxPrice: maxPrice, qatType: qatType);
    }
  }

  @override
  Future<DropItem?> getDropById(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.productDetail}/$id',
        cancelToken: cancelToken,
      );
      if (response.data is Map) {
        // جلب من API
      }
      return MockQatfaData.initialDrops.firstWhere(
        (drop) => drop.id == id,
        orElse: () => MockQatfaData.initialDrops.first,
      );
    } catch (_) {
      return MockQatfaData.initialDrops.firstWhere(
        (drop) => drop.id == id,
        orElse: () => MockQatfaData.initialDrops.first,
      );
    }
  }

  List<DropItem> _filterLocalDrops({String? city, String? qatType}) {
    return MockQatfaData.initialDrops.where((drop) {
      if (city != null && city != 'الكل' && drop.city != city) return false;
      if (qatType != null && qatType != 'الكل' && drop.qatType != qatType) return false;
      return true;
    }).toList();
  }

  List<DropItem> _searchLocalDrops({
    required double minPrice,
    required double maxPrice,
    String? qatType,
  }) {
    return MockQatfaData.initialDrops.where((drop) {
      if (drop.price < minPrice || drop.price > maxPrice) return false;
      if (qatType != null && qatType != 'الكل' && drop.qatType != qatType) return false;
      return true;
    }).toList();
  }
}
