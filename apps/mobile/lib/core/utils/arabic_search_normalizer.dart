/// أداة تطبيع وبحث النصوص العربية لمنع الاستعلامات العقيمة
/// مطابقة لقسم 4.1 في وثيقة استراتيجية الأداء الميداني
class ArabicSearchNormalizer {
  ArabicSearchNormalizer._();

  /// دالة تطبيع النص العربي:
  /// - إزالة التشكيل (الحركات والتنوين)
  /// - توحيد أشكال الألف (إ، أ، آ، ا) -> ا
  /// - توحيد التاء المربوطة (ة) -> ه
  /// - توحيد الياء والياء المقصورة (ى) -> ي
  /// - إزالة الكشيدة التطويلية (ـ)
  /// - تقليص الفراغات الزائدة
  static String normalize(String text) {
    if (text.isEmpty) return '';
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // إزالة التشكيل
        .replaceAll(RegExp(r'[إأآا]'), 'ا') // توحيد الألفات
        .replaceAll('ة', 'ه') // توحيد التاء المربوطة
        .replaceAll('ى', 'ي') // توحيد الياء
        .replaceAll('ـ', '') // إزالة الكشيدة التطويلية
        .replaceAll(RegExp(r'\s+'), ' '); // تقليص الفراغات
  }

  /// فحص ما إذا كان النص المصدر يحتوي على استعلام البحث بعد التطبيع
  static bool matches(String source, String query) {
    if (query.trim().isEmpty) return true;
    final normalizedSource = normalize(source);
    final normalizedQuery = normalize(query);
    return normalizedSource.contains(normalizedQuery);
  }
}
