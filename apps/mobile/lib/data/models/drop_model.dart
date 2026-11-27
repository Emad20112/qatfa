import 'package:equatable/equatable.dart';

/// نموذج بيانات القطفة اليومية (Daily Drop Model)
class DropModel extends Equatable {
  final String id;
  final String title;
  final String qatType;          // همداني، أرحبي، شامي، عنسي، خولاني...
  final String qualityTier;       // رووس، عوارض، قطل، جمام، سمين
  final double price;
  final double? originalPrice;
  final String unit;              // حبة، كيلو، كيس
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final bool isSellerVerified;
  final String marketName;
  final String cityName;
  final bool isAvailable;
  final String harvestTimeText;  // اليوم الساعة 4:30 فجراً
  final String softnessDegree;   // طري جداً (خضيري)
  final String branchPercentage; // 90% أوراق غضة
  final String preservationMethod; // خيش مبلل ومكيف بالكامل
  final DateTime createdAt;

  const DropModel({
    required this.id,
    required this.title,
    required this.qatType,
    required this.qualityTier,
    required this.price,
    this.originalPrice,
    this.unit = 'حبة',
    required this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    this.isSellerVerified = true,
    required this.marketName,
    required this.cityName,
    this.isAvailable = true,
    this.harvestTimeText = 'اليوم 4:30 فجراً',
    this.softnessDegree = 'طري جداً (خضيري)',
    this.branchPercentage = '90% أوراق غضة',
    this.preservationMethod = 'خيش مبلل ومكيف بالكامل',
    required this.createdAt,
  });

  factory DropModel.fromJson(Map<String, dynamic> json) {
    return DropModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      qatType: json['qatType']?.toString() ?? 'همداني',
      qualityTier: json['qualityTier']?.toString() ?? 'رووس',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      unit: json['unit']?.toString() ?? 'حبة',
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sellerId: json['sellerId']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? 'مقاوتي معتمد',
      sellerPhone: json['sellerPhone']?.toString() ?? '777000000',
      isSellerVerified: json['isSellerVerified'] as bool? ?? true,
      marketName: json['marketName']?.toString() ?? 'سوق الملح',
      cityName: json['cityName']?.toString() ?? 'صنعاء',
      isAvailable: json['isAvailable'] as bool? ?? true,
      harvestTimeText: json['harvestTimeText']?.toString() ?? 'اليوم 4:30 فجراً',
      softnessDegree: json['softnessDegree']?.toString() ?? 'طري جداً (خضيري)',
      branchPercentage: json['branchPercentage']?.toString() ?? '90% أوراق غضة',
      preservationMethod: json['preservationMethod']?.toString() ?? 'خيش مبلل ومكيف بالكامل',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'qatType': qatType,
      'qualityTier': qualityTier,
      'price': price,
      'originalPrice': originalPrice,
      'unit': unit,
      'imageUrls': imageUrls,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'isSellerVerified': isSellerVerified,
      'marketName': marketName,
      'cityName': cityName,
      'isAvailable': isAvailable,
      'harvestTimeText': harvestTimeText,
      'softnessDegree': softnessDegree,
      'branchPercentage': branchPercentage,
      'preservationMethod': preservationMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, title, price, isAvailable, createdAt];
}
