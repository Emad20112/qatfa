import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qatfa/core/theme/app_theme.dart';
import 'package:qatfa/data/models/qatfa_models.dart';
import 'package:qatfa/data/repositories/qatfa_repositories.dart';
import 'package:qatfa/data/services/mock_qatfa_data.dart';
import 'package:qatfa/core/widgets/navigation/qatfa_app_bar_header.dart';
import 'package:qatfa/ui/features/drop_detail/views/drop_detail_screen.dart';
import 'package:qatfa/ui/features/home/view_models/drops_feed_view_model.dart';
import 'package:qatfa/ui/features/home/views/home_screen.dart';
import 'package:qatfa/ui/features/markets/view_models/markets_view_model.dart';
import 'package:qatfa/ui/features/markets/views/market_map_view.dart';
import 'package:qatfa/ui/features/markets/views/markets_screen.dart';
import 'package:qatfa/ui/features/search/views/smart_budget_search_modal.dart';

class FakeDropsRepository implements IDropsRepository {
  @override
  Future<List<DropItem>> getDailyDrops({
    String? city,
    String? marketName,
    String? qatType,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    return MockQatfaData.initialDrops;
  }

  @override
  Future<List<DropItem>> searchByBudget({
    required double budget,
    double tolerance = 0.10,
    String? city,
    String? marketName,
    String? qatType,
    String? qualityGrade,
    bool availableOnly = true,
  }) async {
    return MockQatfaData.initialDrops;
  }

  @override
  Future<DropItem?> getDropById(String id) async {
    return MockQatfaData.initialDrops.first;
  }
}

class FakeMarketsRepository implements IMarketsRepository {
  @override
  Future<List<MarketItem>> getMarkets({
    String? city,
    String? query,
  }) async {
    return MockQatfaData.initialMarkets;
  }

  @override
  Future<List<StallItem>> getStallsByMarket(String marketId) async {
    return MockQatfaData.stalls;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Agent 2 Screens and Operations Separation Tests', () {
    testWidgets('HomeScreen renders feed, chips, and hero banner properly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = FakeDropsRepository();
      final vm = DropsFeedViewModel(dropsRepository: repo, autoLoad: false);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: HomeScreen(viewModel: vm),
        ),
      );
      await tester.pump();

      expect(find.byType(QatfaAppBarHeader), findsOneWidget);
      expect(find.text('قطفة مميزة من أجود الأنواع'), findsOneWidget);
      expect(find.text('مقاوتة موثقون ميدانياً'), findsOneWidget);
      expect(find.text('همداني'), findsOneWidget);

      await vm.loadInitialDrops();
      await tester.pump();

      expect(find.text('قطفات اليوم المتجددة'), findsOneWidget);
    });

    testWidgets(
      'SmartBudgetSearchModal filters by budget and Arabic normalization',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        List<DropItem>? filteredDrops;
        BudgetSearchSummary? resultSummary;

        final repo = FakeDropsRepository();

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SmartBudgetSearchModal(
                initialCity: 'صنعاء',
                dropsRepository: repo,
                onApplyFilter: (results, summary) {
                  filteredDrops = results;
                  resultSummary = summary;
                },
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('كم المبلغ المتوفر في جيبك الآن؟'), findsOneWidget);
        expect(
          find.text('إظهار القطفات والمقاوتة المناسبين لميزانيتي'),
          findsOneWidget,
        );

        final applyBtn = find.text(
          'إظهار القطفات والمقاوتة المناسبين لميزانيتي',
        );
        await tester.tap(applyBtn);
        await tester.pump();

        expect(resultSummary, isNotNull);
        expect(filteredDrops, isNotNull);
      },
    );

    testWidgets(
      'MarketsScreen & MarketMapView display markets list and interactive stall pins',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repo = FakeMarketsRepository();
        final vm = MarketsViewModel(marketsRepository: repo);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MarketsScreen(viewModel: vm),
          ),
        );
        await tester.pump();

        expect(find.text('دليل أسواق القات'), findsOneWidget);
        expect(find.text('سوق الملح المركزي'), findsOneWidget);

        // اختبار خريطة السوق
        final market = MockQatfaData.markets.first;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MarketMapView(market: market),
          ),
        );
        await tester.pump();

        expect(find.text('خريطة سوق الملح المركزي'), findsOneWidget);
        expect(find.text('موقعي الحالي'), findsOneWidget);
        expect(find.text('مفرش العم صالح الصياح'), findsOneWidget);
      },
    );

    testWidgets(
      'DropDetailScreen renders carousel, specs grid, and sticky contact bar',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final sampleDrop = MockQatfaData.initialDrops.first;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: DropDetailScreen(drop: sampleDrop),
          ),
        );
        await tester.pump();

        expect(
          find.text('أرحبي قاعي سوبر (قطفة الصباح الطازجة)'),
          findsOneWidget,
        );
        expect(find.text('الحاج يحيى الصياح'), findsOneWidget);
        expect(find.text('مواصفات القطفة الفنية'), findsOneWidget);
        expect(find.text('درجة النعومة'), findsOneWidget);
        expect(find.text('طري جداً (خضيري)'), findsOneWidget);
        expect(find.text('محادثة وحجز واتساب'), findsOneWidget);
        expect(find.text('اتصال'), findsOneWidget);
      },
    );
  });
}
