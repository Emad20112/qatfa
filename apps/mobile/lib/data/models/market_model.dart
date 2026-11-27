import 'package:equatable/equatable.dart';

/// نموذج بيانات السوق الشعبي (Market Model)
class MarketModel extends Equatable {
  final int id;
  final String name;
  final String city;
  final String locationDescription;
  final int activeSellersCount;
  final double rating;
  final String workingHours;
  final String? imageUrl;
  final double latitude;
  final double longitude;

  const MarketModel({
    required this.id,
    required this.name,
    required this.city,
    required this.locationDescription,
    required this.activeSellersCount,
    required this.rating,
    required this.workingHours,
    this.imageUrl,
    this.latitude = 15.3547,
    this.longitude = 44.2066,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? 'صنعاء',
      locationDescription: json['locationDescription']?.toString() ?? '',
      activeSellersCount: (json['activeSellersCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      workingHours: json['workingHours']?.toString() ?? '6:00 ص - 10:00 م',
      imageUrl: json['imageUrl']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 15.3547,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 44.2066,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'locationDescription': locationDescription,
      'activeSellersCount': activeSellersCount,
      'rating': rating,
      'workingHours': workingHours,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [id, name, city];
}

/// نموذج بيانات مفرش المقاوتي بالسوق (Market Stall Model)
class StallModel extends Equatable {
  final String id;
  final String stallNumber;
  final String sellerName;
  final String phoneNumber;
  final bool isVerified;
  final int marketId;
  final String marketName;
  final bool hasActiveDrops;
  final double rating;
  final double latitude;
  final double longitude;

  const StallModel({
    required this.id,
    required this.stallNumber,
    required this.sellerName,
    required this.phoneNumber,
    this.isVerified = true,
    required this.marketId,
    required this.marketName,
    this.hasActiveDrops = true,
    this.rating = 4.9,
    required this.latitude,
    required this.longitude,
  });

  factory StallModel.fromJson(Map<String, dynamic> json) {
    return StallModel(
      id: json['id']?.toString() ?? '',
      stallNumber: json['stallNumber']?.toString() ?? '1',
      sellerName: json['sellerName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
      marketId: (json['marketId'] as num?)?.toInt() ?? 0,
      marketName: json['marketName']?.toString() ?? '',
      hasActiveDrops: json['hasActiveDrops'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, stallNumber, sellerName, hasActiveDrops];
}
