import 'package:flutter/material.dart';
import 'main_shell_screen.dart';

/// مسارات وتوجيه تطبيق قطفة (App Router)
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String dropDetail = '/drop-detail';
  static const String searchBudget = '/search-budget';
  static const String marketDetail = '/market-detail';
  static const String quickPublish = '/quick-publish';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      default:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
    }
  }
}
