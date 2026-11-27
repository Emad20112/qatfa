import 'package:flutter/foundation.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../domain/models/profile_models.dart';

/// ViewModel شاشة الملف الشخصي وإعدادات الحساب
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedOut = false;
  bool get isLoggedOut => _isLoggedOut;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _repository.getProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchRole(AccountRole role) async {
    _profile = await _repository.switchRole(role);
    notifyListeners();
  }

  Future<void> updatePersonalInfo({
    required String fullName,
    required String governorate,
    required String storeName,
  }) async {
    _profile = await _repository.updatePersonalInfo(
      fullName: fullName,
      governorate: governorate,
      storeName: storeName,
    );
    notifyListeners();
  }

  Future<void> toggleMuteReviewNotifications(bool mute) async {
    _profile = await _repository.toggleMuteReviewNotifications(mute);
    notifyListeners();
  }

  Future<void> togglePushNewDrops(bool enabled) async {
    _profile = await _repository.togglePushNewDrops(enabled);
    notifyListeners();
  }

  Future<void> markNotificationsRead() async {
    _profile = await _repository.markNotificationsRead();
    notifyListeners();
  }

  void logout() {
    _isLoggedOut = true;
    notifyListeners();
  }

  void restoreDemoSession() {
    _isLoggedOut = false;
    notifyListeners();
  }
}
