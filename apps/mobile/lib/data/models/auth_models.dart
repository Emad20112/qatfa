import 'package:equatable/equatable.dart';

/// بيانات المستخدم المصادق في منصة قطفة
class AuthUser extends Equatable {
  final String id;
  final String phoneNumber;
  final String fullName;
  final String role;
  final bool isActive;
  final String? storeId;

  const AuthUser({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    this.role = 'CUSTOMER',
    this.isActive = true,
    this.storeId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'مستخدم قطفة',
      role: json['role']?.toString() ?? 'CUSTOMER',
      isActive: json['isActive'] ?? true,
      storeId: json['storeId']?.toString() ?? json['store']?['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'role': role,
      'isActive': isActive,
      'storeId': storeId,
    };
  }

  bool get isSeller => role == 'SELLER' || role == 'VENDOR';
  bool get isAdmin => role == 'ADMIN' || role == 'MODERATOR';

  @override
  List<Object?> get props => [id, phoneNumber, fullName, role, isActive, storeId];
}

/// نتيجة طلب رمز التحقق OTP
class OtpRequestResult extends Equatable {
  final int retryAfterSeconds;
  final String? demoOtp;
  final String message;

  const OtpRequestResult({
    this.retryAfterSeconds = 60,
    this.demoOtp,
    this.message = 'تم إرسال رمز التحقق بنجاح',
  });

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    return OtpRequestResult(
      retryAfterSeconds: json['retryAfterSeconds'] ?? 60,
      demoOtp: json['demoOtp']?.toString(),
      message: json['message']?.toString() ?? 'تم إرسال رمز التحقق بنجاح',
    );
  }

  @override
  List<Object?> get props => [retryAfterSeconds, demoOtp, message];
}

/// نتيجة التحقق الناجح وتسجيل الدخول
class AuthResult extends Equatable {
  final String token;
  final AuthUser user;
  final bool isNewUser;

  const AuthResult({
    required this.token,
    required this.user,
    this.isNewUser = false,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token']?.toString() ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      isNewUser: json['isNewUser'] ?? false,
    );
  }

  @override
  List<Object?> get props => [token, user, isNewUser];
}
