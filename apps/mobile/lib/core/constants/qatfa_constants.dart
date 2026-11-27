/// ثوابت المحافظات والمدن المعتمدة في الجمهورية اليمنية
class QatfaGeoConstants {
  QatfaGeoConstants._();

  static const String defaultCity = 'صنعاء';

  static const List<String> supportedCities = [
    'صنعاء',
    'عدن',
    'تعز',
    'إب',
    'الحديدة',
    'ذمار',
  ];

  static const List<String> marketsFilterOptions = [
    'الكل',
    'صنعاء',
    'الحديدة',
    'تعز',
    'إب',
    'عدن',
  ];
}

/// ثوابت تصنيفات وأنواع القات المعتمدة شعبياً
class QatfaClassificationConstants {
  QatfaClassificationConstants._();

  static const String allFilter = 'الكل';

  static const List<String> qatTypes = [
    allFilter,
    'همداني',
    'شامي',
    'أرحبي',
    'قعطبي',
    'عنسي',
    'رداعي',
    'غيلي',
  ];

  static const List<String> qualityGrades = [
    'رووس',
    'عوارض',
    'قطل',
    'جمام',
    'سمين',
  ];

  static const List<String> units = ['حبة', 'حزمة', 'قبضة', 'كيلو', 'كيس'];
}

/// ثوابت ومعايير الأداء والشبكة
class QatfaPerformanceConstants {
  QatfaPerformanceConstants._();

  /// نافذة التهدئة قبل إطلاق البحث (ms)
  static const int searchDebounceMs = 350;

  /// عتبة بدء الجلب المسبق في التمرير اللانهائي (85%)
  static const double paginationScrollThreshold = 0.85;

  /// نسبة هامش التفاوت في البحث الذكي بالميزانية (±10%)
  static const double budgetTolerancePercentage = 0.10;

  /// الحد الأقصى الافتراضي للعناصر في الصفحة الواحدة
  static const int defaultPageLimit = 20;
}
