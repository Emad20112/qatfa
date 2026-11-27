/// دور المستخدم الحالي في التطبيق (تبديل فوري بين المشتري والمقاوتي)
enum AccountRole {
  buyer,
  seller,
}

/// نموذج السوق أو المفرش المفضل (بديلاً عن عناوين التوصيل في نطاق MVP)
class FavoriteMarketStall {
  final String id;
  final String marketName;
  final String governorate;
  final String stallLabel;
  final bool isOpenNow;

  const FavoriteMarketStall({
    required this.id,
    required this.marketName,
    required this.governorate,
    required this.stallLabel,
    this.isOpenNow = true,
  });
}

/// نموذج الملف الشخصي وإعدادات الحساب
class UserProfile {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String governorate;
  final String storeName;
  final bool isVerified;
  final double rating;
  final AccountRole activeRole;
  final int successfulInquiriesCount;
  final int activeBookingsCount;
  final int favoriteDropsCount;
  final int unreadNotificationsCount;
  final bool muteReviewNotifications;
  final bool pushNewDropsEnabled;
  final List<FavoriteMarketStall> favoriteMarkets;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.governorate,
    required this.storeName,
    required this.isVerified,
    required this.rating,
    required this.activeRole,
    required this.successfulInquiriesCount,
    required this.activeBookingsCount,
    required this.favoriteDropsCount,
    required this.unreadNotificationsCount,
    this.muteReviewNotifications = false,
    this.pushNewDropsEnabled = true,
    this.favoriteMarkets = const [],
  });

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? governorate,
    String? storeName,
    bool? isVerified,
    double? rating,
    AccountRole? activeRole,
    int? successfulInquiriesCount,
    int? activeBookingsCount,
    int? favoriteDropsCount,
    int? unreadNotificationsCount,
    bool? muteReviewNotifications,
    bool? pushNewDropsEnabled,
    List<FavoriteMarketStall>? favoriteMarkets,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      governorate: governorate ?? this.governorate,
      storeName: storeName ?? this.storeName,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      activeRole: activeRole ?? this.activeRole,
      successfulInquiriesCount:
          successfulInquiriesCount ?? this.successfulInquiriesCount,
      activeBookingsCount: activeBookingsCount ?? this.activeBookingsCount,
      favoriteDropsCount: favoriteDropsCount ?? this.favoriteDropsCount,
      unreadNotificationsCount:
          unreadNotificationsCount ?? this.unreadNotificationsCount,
      muteReviewNotifications:
          muteReviewNotifications ?? this.muteReviewNotifications,
      pushNewDropsEnabled: pushNewDropsEnabled ?? this.pushNewDropsEnabled,
      favoriteMarkets: favoriteMarkets ?? this.favoriteMarkets,
    );
  }
}
