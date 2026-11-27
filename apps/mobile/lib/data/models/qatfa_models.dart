/// نموذج بيانات القطفة اليومية (Daily Drop Item Model)
class DropItem {
  final String id;
  final String title;
  final String qatType; // همداني، شامي، قعطبي، عنسي، أرحبي، رداعي...
  final String qualityGrade; // رووس، عوارض، قطل، جمام، سمين
  final String sellerName;
  final String sellerPhone;
  final bool isVerifiedSeller;
  final double rating;
  final int reviewsCount;
  final int completedSales;
  final String marketName;
  final String city;
  final String stallLocation;
  final int price; // بالريال اليمني
  final int? oldPrice;
  final String unit; // حبة، حزمة، قبضة، كيلو
  final String? imageUrl;
  final List<String> galleryImages;
  final bool isFresh;
  final bool isAvailable;
  final String updatedAtText; // "منذ 8 دقائق"
  final String harvestTimeText; // "اليوم الساعة 4:30 فجراً"
  final String freshnessLevel; // "طري جداً (خضيري)"
  final String leafToStemRatio; // "90% أوراق غضة"
  final String preservationMethod; // "خيش مبلل ومكيف بالكامل"

  const DropItem({
    required this.id,
    required this.title,
    required this.qatType,
    required this.qualityGrade,
    required this.sellerName,
    required this.sellerPhone,
    this.isVerifiedSeller = true,
    this.rating = 4.9,
    this.reviewsCount = 128,
    this.completedSales = 120,
    required this.marketName,
    required this.city,
    required this.stallLocation,
    required this.price,
    this.oldPrice,
    this.unit = 'حبة',
    this.imageUrl,
    this.galleryImages = const [],
    this.isFresh = true,
    this.isAvailable = true,
    required this.updatedAtText,
    this.harvestTimeText = 'اليوم الساعة 4:30 فجراً',
    this.freshnessLevel = 'طري جداً (خضيري)',
    this.leafToStemRatio = '90% أوراق غضة',
    this.preservationMethod = 'خيش مبلل ومكيف بالكامل',
  });
}

/// نموذج بيانات السوق الشعبي (Market Summary Model)
class MarketItem {
  final String id;
  final String name;
  final String city;
  final String address;
  final double rating;
  final int reviewsCount;
  final int activeSellersCount;
  final String workingHours;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final bool isActive;

  const MarketItem({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.activeSellersCount,
    required this.workingHours,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
  });
}

/// نموذج بيانات مفرش المقاوتي داخل السوق (Market Stall Pin Model)
class StallItem {
  final String id;
  final String sellerName;
  final String stallNumber;
  final String marketId;
  final String marketName;
  final String city;
  final String dropTitle;
  final int price;
  final String unit;
  final String phoneNumber;
  final bool isVerified;
  final bool isAvailable; // متوفر الآن (أخضر) أو نفد (رمادي)
  final double latitudeOffset; // إزاحة نسبية داخل خريطة السوق
  final double longitudeOffset;
  final String? dropImageUrl;

  const StallItem({
    required this.id,
    required this.sellerName,
    required this.stallNumber,
    required this.marketId,
    required this.marketName,
    required this.city,
    required this.dropTitle,
    required this.price,
    this.unit = 'حبة',
    required this.phoneNumber,
    this.isVerified = true,
    this.isAvailable = true,
    required this.latitudeOffset,
    required this.longitudeOffset,
    this.dropImageUrl,
  });
}
