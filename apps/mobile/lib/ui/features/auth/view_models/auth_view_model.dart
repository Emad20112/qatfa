import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../data/models/auth_models.dart';
import '../../../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  error,
}

class AuthViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String _phoneNumber = '';
  String _fullName = '';
  String? _demoOtp;
  AuthUser? _user;

  int _resendCountdown = 0;
  Timer? _countdownTimer;

  AuthViewModel({IAuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  AuthStatus get status => _status;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isOtpSent => _status == AuthStatus.otpSent;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  String? get errorMessage => _errorMessage;
  String get phoneNumber => _phoneNumber;
  String get fullName => _fullName;
  String? get demoOtp => _demoOtp;
  AuthUser? get user => _user;
  int get resendCountdown => _resendCountdown;
  bool get canResend => _resendCountdown <= 0 && !isLoading;

  /// تنظيف وتوحيد رقم الهاتف
  static String cleanPhone(String raw) {
    String cleaned = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('00967')) {
      cleaned = '+967${cleaned.substring(5)}';
    } else if (cleaned.startsWith('967')) {
      cleaned = '+967${cleaned.substring(3)}';
    } else if (cleaned.startsWith('0')) {
      cleaned = '+967${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+967') && cleaned.isNotEmpty) {
      cleaned = '+967$cleaned';
    }
    return cleaned;
  }

  /// التحقق من صحة الرقم اليمني
  static bool isValidYemeniPhone(String raw) {
    final cleaned = cleanPhone(raw);
    final regExp = RegExp(r'^\+967(77|78|73|71|70)[0-9]{7}$');
    return regExp.hasMatch(cleaned);
  }

  /// تحديد مزود الخدمة اليمني وفق البادئة
  static String getYemeniOperator(String raw) {
    final cleaned = cleanPhone(raw);
    if (cleaned.length < 7) return '';
    final prefix = cleaned.replaceFirst('+967', '').substring(0, 2);
    switch (prefix) {
      case '77':
      case '78':
        return 'يمن موبايل';
      case '73':
        return 'يو (YOU)';
      case '71':
        return 'سبأفون';
      case '70':
        return 'واي (Y)';
      default:
        return 'شبكة يمنية';
    }
  }

  /// طلب إرسال رمز التحقق OTP
  Future<bool> requestOtp({
    required String phone,
    String? name,
  }) async {
    final trimmedPhone = phone.trim();
    if (!isValidYemeniPhone(trimmedPhone)) {
      _errorMessage = 'يرجى إدخال رقم هاتف يمني صحيح يبدأ بـ 77 أو 78 أو 73 أو 71 أو 70';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _phoneNumber = cleanPhone(trimmedPhone);
    if (name != null && name.trim().isNotEmpty) {
      _fullName = name.trim();
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.requestOtp(
        phoneNumber: _phoneNumber,
        fullName: _fullName.isNotEmpty ? _fullName : null,
      );

      _demoOtp = result.demoOtp;
      _status = AuthStatus.otpSent;
      _startCountdown(result.retryAfterSeconds);
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// إعادة إرسال رمز التحقق
  Future<bool> resendOtp() async {
    if (!canResend || _phoneNumber.isEmpty) return false;
    return requestOtp(phone: _phoneNumber, name: _fullName);
  }

  /// التحقق من الرمز المدخل وتسجيل الدخول
  Future<bool> verifyOtp(String code) async {
    final trimmedCode = code.trim();
    if (trimmedCode.length != 6) {
      _errorMessage = 'يرجى إدخال رمز التحقق المكون من 6 أرقام';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.verifyOtp(
        phoneNumber: _phoneNumber,
        code: trimmedCode,
        fullName: _fullName.isNotEmpty ? _fullName : null,
      );

      _user = result.user;
      _status = AuthStatus.authenticated;
      _cancelCountdown();
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _status = AuthStatus.initial;
    _phoneNumber = '';
    _fullName = '';
    _demoOtp = null;
    _cancelCountdown();
    notifyListeners();
  }

  void _startCountdown(int seconds) {
    _cancelCountdown();
    _resendCountdown = seconds > 0 ? seconds : 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        _resendCountdown -= 1;
        notifyListeners();
      } else {
        _resendCountdown = 0;
        _cancelCountdown();
        notifyListeners();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _cancelCountdown();
    super.dispose();
  }
}
