import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:googleform_client/l10n/app_localizations.dart';
import 'services/google_auth_service.dart';
import 'services/locale_service.dart';
import 'services/connectivity_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/app_icons.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('PlatformError: $error\n$stack');
    }
    // Suppress PredictiveBackEvent crashes on Android 14+
    if (error.toString().contains('PredictiveBackEvent')) {
      return true;
    }
    return true;
  };

  await LocaleService.instance.initialize();
  ConnectivityService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GoogleAuthService _authService = GoogleAuthService();
  final LocaleService _localeService = LocaleService.instance;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initApp();
    _localeService.localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localeService.localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (_localeService.followsSystem && mounted) {
      setState(() {});
    }
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initApp() async {
    try {
      await _authService.initialize();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Auth initialization failed: $e');
      }
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localeService.localeNotifier,
      builder: (context, _) {
        // Always pass a concrete locale. Passing `null` after a fixed locale
        // (e.g. fr) can leave MaterialApp stuck on the previous language.
        final resolvedLocale = _localeService.activeLocale();
        return MaterialApp(
          title: 'Form',
          debugShowCheckedModeBanner: false,
          locale: resolvedLocale,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            return _localeService.resolveLocale(deviceLocale);
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleService.supportedLocales,
          theme: ThemeData(
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF673AB7)),
            useMaterial3: true,
            iconTheme: AppIcons.theme,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF202124),
              elevation: 0,
              iconTheme: AppIcons.theme,
              actionsIconTheme: AppIcons.theme,
            ),
          ),
          home: !_initialized
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF673AB7)),
                  ),
                )
              : _authService.isLoggedIn
                  ? const HomeScreen()
                  : const LoginScreen(),
        );
      },
    );
  }
}
