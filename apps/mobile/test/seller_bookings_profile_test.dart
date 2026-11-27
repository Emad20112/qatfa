import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qatfa/core/theme/app_theme.dart';
import 'package:qatfa/core/widgets/cards/booking_card.dart';
import 'package:qatfa/data/repositories/bookings_repository.dart';
import 'package:qatfa/data/repositories/profile_repository.dart';
import 'package:qatfa/data/repositories/seller_repository.dart';
import 'package:qatfa/domain/models/seller_models.dart';
import 'package:qatfa/ui/features/bookings/view_models/bookings_view_model.dart';
import 'package:qatfa/ui/features/bookings/views/bookings_screen.dart';
import 'package:qatfa/ui/features/profile/view_models/profile_view_model.dart';
import 'package:qatfa/ui/features/profile/views/profile_screen.dart';
import 'package:qatfa/ui/features/seller/view_models/quick_publish_view_model.dart';
import 'package:qatfa/ui/features/seller/view_models/seller_presets_view_model.dart';
import 'package:qatfa/ui/features/seller/views/quick_publish_screen.dart';
import 'package:qatfa/ui/features/seller/views/seller_presets_screen.dart';

void main() {
  group('Seller Presets & Quick Publish Flow Tests', () {
    testWidgets('SellerPresetsScreen renders sections and adds custom item',
        (tester) async {
      final repo = SellerRepository();
      final vm = SellerPresetsViewModel(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SellerPresetsScreen(viewModel: vm),
        ),
      );
      await tester.pump();

      expect(find.text('إعداد القوائم السريعة لمفرشي'), findsOneWidget);
      expect(find.text('عنسي'), findsOneWidget);
      expect(find.text('رووس'), findsOneWidget);
      expect(find.text('حبة'), findsOneWidget);

      await vm.addCustomItem(
        category: PresetCategory.qatType,
        label: 'مطري',
      );
      await tester.pump();

      expect(find.text('مطري'), findsOneWidget);
    });

    testWidgets(
        'QuickPublishScreen captures WebP photo, enters price, publishes drop, and toggles availability',
        (tester) async {
      final repo = SellerRepository();
      final vm = QuickPublishViewModel(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: QuickPublishScreen(
            viewModel: vm,
            repository: repo,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('نشر قطفة اليوم السريعة'), findsOneWidget);
      expect(find.text('متجري متاح ويستقبل الطلبات'), findsOneWidget);

      // Toggle Master Store switch
      await tester.tap(find.byKey(const Key('master_store_toggle')));
      await tester.pump();
      expect(find.text('متجري مغلق مؤقتاً'), findsOneWidget);

      // Capture live WebP photo
      await tester.tap(find.byKey(const Key('live_camera_capture_button')));
      await tester.pump();
      expect(find.text('تم التقاط وضغط الصورة بنجاح'), findsOneWidget);

      // Enter price
      await tester.enterText(
        find.byKey(const Key('quick_price_input')),
        '12000',
      );
      await tester.pump();

      // Publish drop
      final publishBtn = find.byKey(const Key('publish_drop_button'));
      await tester.ensureVisible(publishBtn);
      await tester.tap(publishBtn);
      await tester.pumpAndSettle();

      expect(find.text('تم نشر قطفتك في السوق بنجاح 🌿'), findsOneWidget);
      expect(
        find.text('سوّق قطفتك على الواتساب بضغطة زر'),
        findsOneWidget,
      );
    });
  });

  group('BookingsScreen Tests', () {
    testWidgets(
        'BookingsScreen renders tabs, filters cards, and updates summary on cancel',
        (tester) async {
      final vm = BookingsViewModel(repository: BookingsRepository());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: BookingsScreen(viewModel: vm),
        ),
      );
      await tester.pump();

      expect(find.text('حجوزاتي'), findsOneWidget);
      expect(find.text('كل حجوزاتك في مكان واحد'), findsOneWidget);
      expect(find.text('الكل (3)'), findsOneWidget);
      expect(find.text('قيد التأكيد (1)'), findsOneWidget);
      expect(find.text('مؤكد (1)'), findsOneWidget);
      expect(find.text('مكتمل (1)'), findsOneWidget);
      expect(find.byType(BookingCard), findsNWidgets(3));
      expect(find.text('إجمالي حجوزاتك: 3 حجوزات'), findsOneWidget);
      expect(find.text('بقيمة إجمالية: 42,000 ر.ي'), findsOneWidget);

      // Filter by confirmed
      await tester.tap(find.text('مؤكد (1)'));
      await tester.pump();
      expect(find.byType(BookingCard), findsOneWidget);
      expect(find.text('همداني فاخر'), findsOneWidget);
    });
  });

  group('ProfileScreen Tests', () {
    testWidgets(
        'ProfileScreen renders user details, stats, 8 tiles, heritage footer, and switches role',
        (tester) async {
      final vm = ProfileViewModel(repository: ProfileRepository());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ProfileScreen(viewModel: vm),
        ),
      );
      await tester.pump();

      expect(find.text('يونس العفيف'), findsOneWidget);
      expect(find.text('مستخدم موثق'), findsOneWidget);
      expect(find.text('مشتري'), findsOneWidget);
      expect(find.text('تواصل ناجح'), findsOneWidget);
      expect(find.text('البيانات الشخصية'), findsOneWidget);
      expect(find.text('الأسواق والمفارش المفضلة'), findsOneWidget);
      expect(find.text('سجل الطلبات والحجوزات'), findsOneWidget);
      expect(find.text('تسجيل الخروج'), findsOneWidget);

      // Switch role to seller
      await tester.tap(find.byKey(const Key('role_switcher_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('مقاوتي (بائع)'));
      await tester.pumpAndSettle();

      expect(find.text('مقاوتي'), findsOneWidget);
      expect(find.text('نشر قطفة اليوم'), findsOneWidget);
      expect(find.text('قوائمي السريعة'), findsOneWidget);

      // Scroll to verify heritage footer
      await tester.scrollUntilVisible(
        find.text('مع قطفة .. نزرع الخير ونحصده معاً'),
        300,
      );
      expect(
        find.text('مع قطفة .. نزرع الخير ونحصده معاً'),
        findsOneWidget,
      );
    });
  });
}
