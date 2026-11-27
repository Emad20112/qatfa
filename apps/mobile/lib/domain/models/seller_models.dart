/// نموذج الوسائط الملتقطة والمضغوطة تلقائياً بصيغة WebP
class CapturedMediaInfo {
  final String id;
  final String fileName;
  final int originalSizeKb;
  final int compressedWebpSizeKb;
  final int widthPx;
  final int heightPx;
  final DateTime capturedAt;

  const CapturedMediaInfo({
    required this.id,
    required this.fileName,
    required this.originalSizeKb,
    required this.compressedWebpSizeKb,
    this.widthPx = 1080,
    this.heightPx = 810,
    required this.capturedAt,
  });

  double get compressionRatio =>
      originalSizeKb == 0 ? 0 : (1 - (compressedWebpSizeKb / originalSizeKb)) * 100;
}

/// إعدادات القوائم السريعة المسبقة للمقاوتي (Seller Presets)
class SellerPresets {
  final List<String> availableTypes;
  final List<String> selectedTypes;
  final List<String> availableGrades;
  final List<String> selectedGrades;
  final List<String> availableUnits;
  final List<String> selectedUnits;

  const SellerPresets({
    required this.availableTypes,
    required this.selectedTypes,
    required this.availableGrades,
    required this.selectedGrades,
    required this.availableUnits,
    required this.selectedUnits,
  });

  SellerPresets copyWith({
    List<String>? availableTypes,
    List<String>? selectedTypes,
    List<String>? availableGrades,
    List<String>? selectedGrades,
    List<String>? availableUnits,
    List<String>? selectedUnits,
  }) {
    return SellerPresets(
      availableTypes: availableTypes ?? this.availableTypes,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      availableGrades: availableGrades ?? this.availableGrades,
      selectedGrades: selectedGrades ?? this.selectedGrades,
      availableUnits: availableUnits ?? this.availableUnits,
      selectedUnits: selectedUnits ?? this.selectedUnits,
    );
  }
}

/// فئة العنصر المخصص عند إضافته للقوائم المسبقة
enum PresetCategory {
  qatType,
  qualityGrade,
  saleUnit,
}

/// نموذج القطفة المنشورة لدى المقاوتي مع حالة التوفر الفوري
class SellerDropItem {
  final String id;
  final String qatType;
  final String qualityGrade;
  final String unit;
  final int priceYer;
  final bool isAvailable;
  final bool isExpressAd;
  final String? customDescription;
  final CapturedMediaInfo? media;
  final DateTime publishedAt;

  const SellerDropItem({
    required this.id,
    required this.qatType,
    required this.qualityGrade,
    required this.unit,
    required this.priceYer,
    required this.isAvailable,
    this.isExpressAd = false,
    this.customDescription,
    this.media,
    required this.publishedAt,
  });

  String get displayTitle =>
      isExpressAd && (customDescription?.trim().isNotEmpty ?? false)
          ? customDescription!.trim()
          : '$qatType $qualityGrade';

  SellerDropItem copyWith({
    String? id,
    String? qatType,
    String? qualityGrade,
    String? unit,
    int? priceYer,
    bool? isAvailable,
    bool? isExpressAd,
    String? customDescription,
    CapturedMediaInfo? media,
    DateTime? publishedAt,
  }) {
    return SellerDropItem(
      id: id ?? this.id,
      qatType: qatType ?? this.qatType,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      unit: unit ?? this.unit,
      priceYer: priceYer ?? this.priceYer,
      isAvailable: isAvailable ?? this.isAvailable,
      isExpressAd: isExpressAd ?? this.isExpressAd,
      customDescription: customDescription ?? this.customDescription,
      media: media ?? this.media,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
