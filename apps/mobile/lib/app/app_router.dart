import 'package:flutter/material.dart';

import '../data/models/qatfa_models.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/auth/views/otp_verification_screen.dart';
import '../ui/features/auth/view_models/auth_view_model.dart';
import '../ui/features/bookings/views/bookings_screen.dart';
import '../ui/features/drop_detail/views/drop_detail_screen.dart';
import '../ui/features/profile/views/profile_screen.dart';
import '../ui/features/seller/views/quick_publish_screen.dart';
import '../ui/features/seller/views/seller_presets_screen.dart';
import 'main_shell_screen.dart';

/// مسارات وتوجيه تطبيق قطفة (App Router)
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String dropDetail = '/drop-detail';
  static const String quickPublish = '/quick-publish';
  static const String presets = '/seller-presets';
  static const String bookings = '/bookings';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otpVerification:
        final vm = settings.arguments as AuthViewModel?;
        if (vm != null) {
          return MaterialPageRoute(builder: (_) => OtpVerificationScreen(viewModel: vm));
        }
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case quickPublish:
        return MaterialPageRoute(builder: (_) => const QuickPublishScreen());
      case presets:
        return MaterialPageRoute(builder: (_) => const SellerPresetsScreen());
      case bookings:
        return MaterialPageRoute(builder: (_) => const BookingsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case dropDetail:
        final drop = settings.arguments as DropItem?;
        if (drop != null) {
          return MaterialPageRoute(builder: (_) => DropDetailScreen(drop: drop));
        }
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      default:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
    }
  }
}
