import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '213076487226-s24okciln4cab0rt1vipft0q3ju33lm5.apps.googleusercontent.com',
    scopes: [
      'https://www.googleapis.com/auth/forms.body',
      'https://www.googleapis.com/auth/forms.body.readonly',
      'https://www.googleapis.com/auth/forms',
      'https://www.googleapis.com/auth/drive',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.readonly',
      'https://www.googleapis.com/auth/script.projects',
      'https://www.googleapis.com/auth/spreadsheets',
    ],
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
    // Try silent sign-in
    await _googleSignIn.signInSilently();
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