import 'package:dio/dio.dart';
import '../models/qatfa_models.dart';
import '../services/dio_client.dart';
import '../services/api_endpoints.dart';
import '../services/mock_qatfa_data.dart';

/// واجهة مستودع الأسواق والمفارش
abstract class IMarketsRepository {
  Future<List<MarketItem>> getMarkets({String? city, CancelToken? cancelToken});
  Future<List<StallItem>> getStallsByMarket(String marketId, {CancelToken? cancelToken});
}

/// تنفيذ مستودع الأسواق مع دعم التراجع للبيانات المجهزة محلياً
class MarketsRepositoryImpl implements IMarketsRepository {
  final DioClient _client;

  MarketsRepositoryImpl({DioClient? client}) : _client = client ?? DioClient();

  @override
  Future<List<MarketItem>> getMarkets({String? city, CancelToken? cancelToken}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.markets,
        queryParameters: {
          if (city != null && city != 'الكل') 'city': city,
        },
        cancelToken: cancelToken,
      );

      if (response.data is List) {
        // تحويل استجابة API
      }
      return _filterLocalMarkets(city: city);
    } catch (_) {
      return _filterLocalMarkets(city: city);
    }
  }

  @override
  Future<List<StallItem>> getStallsByMarket(String marketId, {CancelToken? cancelToken}) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.stalls}/market/$marketId',
        cancelToken: cancelToken,
      );

      if (response.data is List) {
        // تحويل استجابة API
      }
      return MockQatfaData.stalls.where((stall) => stall.marketId == marketId).toList();
    } catch (_) {
      return MockQatfaData.stalls.where((stall) => stall.marketId == marketId).toList();
    }
  }

  List<MarketItem> _filterLocalMarkets({String? city}) {
    if (city == null || city == 'الكل') {
      return MockQatfaData.initialMarkets;
    }
    return MockQatfaData.initialMarkets.where((m) => m.city == city).toList();
  }
}
