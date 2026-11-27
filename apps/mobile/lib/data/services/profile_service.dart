import '../../domain/models/profile_models.dart';

/// خدمة إدارة بيانات الملف الشخصي وإعدادات الحساب
class ProfileService {
  UserProfile _profile = const UserProfile(
    id: 'usr-yunis-01',
    fullName: 'يونس العفيف',
    phoneNumber: '+967 712 345 678',
    governorate: 'صنعاء',
    storeName: 'مفرش العفيف للقات المختار',
    isVerified: true,
    rating: 5.0,
    activeRole: AccountRole.buyer,
    successfulInquiriesCount: 8,
    activeBookingsCount: 3,
    favoriteDropsCount: 12,
    unreadNotificationsCount: 3,
    muteReviewNotifications: false,
    pushNewDropsEnabled: true,
    favoriteMarkets: [
      FavoriteMarketStall(
        id: 'fav-m-1',
        marketName: 'سوق الملح المركزي',
        governorate: 'صنعاء',
        stallLabel: 'مفرش العم صالح - رقم 14',
        isOpenNow: true,
      ),
      FavoriteMarketStall(
        id: 'fav-m-2',
        marketName: 'سوق علي محسن',
        governorate: 'صنعاء',
        stallLabel: 'مفرش السالمي - رقم 8',
        isOpenNow: true,
      ),
    ],
  );

  Future<UserProfile> fetchProfile() async => _profile;

  Future<UserProfile> updateProfile(UserProfile updated) async {
    _profile = updated;
    return _profile;
  }
}
