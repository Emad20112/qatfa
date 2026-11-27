import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/responsive/text_scaler_boundary.dart';
import 'app/app_router.dart';
import 'app/main_shell_screen.dart';
import 'logic/blocs/drops_feed_bloc.dart';
import 'logic/blocs/markets_bloc.dart';
import 'logic/blocs/city_selector_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QatfaApp());
}

/// التطبيق الرئيسي لمنصة قطفة
class QatfaApp extends StatelessWidget {
  const QatfaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CitySelectorBloc>(
          create: (_) => CitySelectorBloc(),
        ),
        BlocProvider<DropsFeedBloc>(
          create: (_) => DropsFeedBloc()..add(const LoadDropsFeed()),
        ),
        BlocProvider<MarketsBloc>(
          create: (_) => MarketsBloc()..add(const LoadMarkets()),
        ),
      ],
      child: MaterialApp(
        title: 'قطفة - Qatfa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        builder: (context, child) {
          // تطويق التطبيق لحماية الشاشات من انهيار الخطوط الكبيرة RenderFlex overflow
          return Directionality(
            textDirection: TextDirection.rtl,
            child: TextScalerBoundary(
              minScale: 0.85,
              maxScale: 1.30,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        initialRoute: AppRouter.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const MainShellScreen(),
      ),
    );
  }
}
