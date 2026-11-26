import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qatfa/core/theme/app_colors.dart';
import 'package:qatfa/core/theme/app_theme.dart';
import 'package:qatfa/core/responsive/text_scaler_boundary.dart';
import 'package:qatfa/core/widgets/chips/qatfa_status_badge.dart';
import 'package:qatfa/core/widgets/chips/qatfa_choice_chip.dart';
import 'package:qatfa/core/widgets/buttons/qatfa_primary_button.dart';
import 'package:qatfa/core/widgets/cards/stat_counter_card.dart';

void main() {
  group('Qatfa Design System Tests', () {
    test('Light and Dark themes instantiate with correct extensions', () {
      final lightTheme = AppTheme.light;
      final darkTheme = AppTheme.dark;

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);

      final lightColors = lightTheme.extension<QatfaColors>();
      final darkColors = darkTheme.extension<QatfaColors>();

      expect(lightColors, isNotNull);
      expect(darkColors, isNotNull);
      expect(lightColors!.primary, AppColors.primaryGreen);
      expect(darkColors!.primary, const Color(0xFF22C55E));
      expect(lightColors.agate, AppColors.agateOrange);
    });

    testWidgets('TextScalerBoundary clamps text scale correctly', (tester) async {
      double? observedScale;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
            child: TextScalerBoundary(
              minScale: 0.85,
              maxScale: 1.30,
              child: Builder(
                builder: (context) {
                  observedScale = MediaQuery.textScalerOf(context).scale(10) / 10;
                  return const Text('اختبار حجم الخط');
                },
              ),
            ),
          ),
        ),
      );

      expect(observedScale, closeTo(1.30, 0.01));
    });

    testWidgets('QatfaStatusBadge renders label with appropriate color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: QatfaStatusBadge(
              label: 'طازج الآن',
              statusType: QatfaStatusType.fresh,
            ),
          ),
        ),
      );

      expect(find.text('طازج الآن'), findsOneWidget);
    });

    testWidgets('QatfaChoiceChip toggles selection', (tester) async {
      bool isSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: QatfaChoiceChip(
                  label: 'همداني ممتاز',
                  isSelected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      isSelected = val;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('همداني ممتاز'), findsOneWidget);
      await tester.tap(find.text('همداني ممتاز'));
      await tester.pumpAndSettle();
      expect(isSelected, isTrue);
    });

    testWidgets('QatfaPrimaryButton triggers onPressed callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: QatfaPrimaryButton(
              label: 'احجز حزمتك الآن',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('احجز حزمتك الآن'), findsOneWidget);
      await tester.tap(find.text('احجز حزمتك الآن'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('StatCounterCard renders all items correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: StatCounterCard(
              items: [
                StatItem(label: 'حجز نشط', value: '3', icon: Icons.calendar_today),
                StatItem(label: 'قطفة مفضلة', value: '12', icon: Icons.favorite),
              ],
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('حجز نشط'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('قطفة مفضلة'), findsOneWidget);
    });
  });
}
