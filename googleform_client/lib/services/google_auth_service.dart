import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
    scopes: [
      dotenv.env['GOOGLE_SCOPE_FORMS_BODY'] ?? '',
      dotenv.env['GOOGLE_SCOPE_FORMS_BODY_READONLY'] ?? '',
      dotenv.env['GOOGLE_SCOPE_FORMS'] ?? '',
      dotenv.env['GOOGLE_SCOPE_DRIVE'] ?? '',
      dotenv.env['GOOGLE_SCOPE_DRIVE_FILE'] ?? '',
      dotenv.env['GOOGLE_SCOPE_DRIVE_READONLY'] ?? '',
      dotenv.env['GOOGLE_SCOPE_SCRIPT_PROJECTS'] ?? '',
      dotenv.env['GOOGLE_SCOPE_SPREADSHEETS'] ?? '',
    ].where((s) => s.isNotEmpty).toList(),
  );

  GoogleSignInAccount? _currentUser;
  String? _accessToken;

  GoogleSignInAccount? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
      if (account == null) {
        _accessToken = null;
      }
    });
    // Try silent sign-in — wrapped in try-catch to prevent crash
    // when google-services.json is missing or user has never signed in
    try {
      await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('Silent sign-in failed: $e');
    }
  }

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        _currentUser = account;
        final auth = await account.authentication;
        _accessToken = auth.accessToken;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _accessToken = null;
  }

  Future<String?> getFreshAccessToken() async {
    if (_currentUser == null) return null;
    try {
      final auth = await _currentUser!.authentication;
      _accessToken = auth.accessToken;
      return _accessToken;
    } catch (e) {
      debugPrint('Get access token error: $e');
      return null;
    }
  }
}