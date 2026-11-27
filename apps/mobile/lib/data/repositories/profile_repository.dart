import '../../domain/models/profile_models.dart';
import '../services/profile_service.dart';

/// مستودع الملف الشخصي وإعدادات الحساب
class ProfileRepository {
  final ProfileService _service;

  ProfileRepository({ProfileService? service})
      : _service = service ?? ProfileService();

  Future<UserProfile> getProfile() => _service.fetchProfile();

  Future<UserProfile> switchRole(AccountRole role) async {
    final current = await _service.fetchProfile();
    return _service.updateProfile(current.copyWith(activeRole: role));
  }

  Future<UserProfile> updatePersonalInfo({
    required String fullName,
    required String governorate,
    required String storeName,
  }) async {
    final current = await _service.fetchProfile();
    return _service.updateProfile(
      current.copyWith(
        fullName: fullName.trim().isEmpty ? current.fullName : fullName.trim(),
        governorate: governorate,
        storeName:
            storeName.trim().isEmpty ? current.storeName : storeName.trim(),
      ),
    );
  }

  Future<UserProfile> toggleMuteReviewNotifications(bool mute) async {
    final current = await _service.fetchProfile();
    return _service.updateProfile(
      current.copyWith(muteReviewNotifications: mute),
    );
  }

  Future<UserProfile> togglePushNewDrops(bool enabled) async {
    final current = await _service.fetchProfile();
    return _service.updateProfile(
      current.copyWith(pushNewDropsEnabled: enabled),
    );
  }

  Future<UserProfile> markNotificationsRead() async {
    final current = await _service.fetchProfile();
    return _service.updateProfile(
      current.copyWith(unreadNotificationsCount: 0),
    );
  }
}
