import 'package:flutter/material.dart';
import 'services/google_auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GoogleAuthService _authService = GoogleAuthService();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _authService.initialize();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forms for Google',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF673AB7)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF202124),
          elevation: 0,
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
  }
}