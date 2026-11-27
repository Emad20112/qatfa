/// الثوابت وعناوين الـ API الخاصة بمنصة قطفة
class ApiEndpoints {
  ApiEndpoints._();

  /// عنوان الخادم الافتراضي لبيئة التطوير والإنتاج
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  static const String desktopBaseUrl = 'http://localhost:3000/api/v1';

  // نقاط نهاية عروض القطفات (Daily Drops & Products)
  static const String dailyDrops = '/products/daily-drops';
  static const String searchProducts = '/products/search';
  static const String productDetail = '/products';

  // نقاط نهاية الأسواق والمفارش (Markets & Stalls)
  static const String markets = '/stores/markets';
  static const String stalls = '/stores';
  static const String storeDetail = '/stores';

  // التوثيق وإعدادات المقاوتي
  static const String authOtpRequest = '/auth/otp/request';
  static const String authOtpVerify = '/auth/otp/verify';
  static const String sellerPresets = '/stores/presets';
  static const String toggleStoreStatus = '/stores/status';
}
