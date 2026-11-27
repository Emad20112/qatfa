import 'package:flutter_test/flutter_test.dart';
import 'package:qatfa/main.dart';
import 'package:qatfa/core/widgets/navigation/qatfa_bottom_nav_bar.dart';

void main() {
  testWidgets('QatfaApp loads MainShellScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QatfaApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 15));

    // التحقق من ظهور شريط التنقل السفلي وشعار قطفة
    expect(find.byType(QatfaBottomNavBar), findsOneWidget);
    expect(find.text('قـطـفـة'), findsWidgets);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('الأسواق'), findsOneWidget);
  });
}
