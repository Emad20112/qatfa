import 'package:flutter/material.dart';

import '../core/widgets/navigation/qatfa_bottom_nav_bar.dart';
import '../ui/features/bookings/views/bookings_screen.dart';
import '../ui/features/home/views/home_screen.dart';
import '../ui/features/markets/views/markets_screen.dart';
import '../ui/features/profile/views/profile_screen.dart';
import '../ui/features/seller/views/quick_publish_screen.dart';

/// الشاشة الهيكلية الرئيسية للتطبيق (Main Shell Screen)
/// تربط شريط التنقل السفلي المطور مع التبويبات الأربعة وزر النشر العائم
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openQuickPublish() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuickPublishScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onOpenMarkets: () => _onTabSelected(1),
          ),
          const MarketsScreen(),
          const BookingsScreen(),
          ProfileScreen(
            onPostDropTap: _openQuickPublish,
            onNavigateBookings: () => _onTabSelected(2),
          ),
        ],
      ),
      bottomNavigationBar: QatfaBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        onPostDropTap: _openQuickPublish,
      ),
    );
  }
}
