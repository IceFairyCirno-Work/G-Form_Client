import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'google_auth_service.dart';

/// Service to call Google Apps Script functions.
/// Used to apply form settings that the REST API doesn't support.
class AppsScriptService {
  static final AppsScriptService _instance = AppsScriptService._internal();
  factory AppsScriptService() => _instance;
  AppsScriptService._internal();

  final GoogleAuthService _authService = GoogleAuthService();
  String get _scriptId =>
      dotenv.env['GOOGLE_APPS_SCRIPT_ID'] ?? '';
  String get _scriptBaseUrl =>
      dotenv.env['GOOGLE_SCRIPT_API_URL'] ?? 'https://script.googleapis.com/v1/scripts';

  /// Whether the service is configured (scriptId is set).
  bool get isConfigured => _scriptId.isNotEmpty;

  /// Apply form settings via Apps Script.
  ///
  /// Returns a map with:
  /// - 'success': bool
  /// - 'applied': `List<String>`? (names of settings that were applied)
  /// - 'errors': `List<String>`? (any per-setting errors)
  /// - 'error': String? (overall error message)
  Future<Map<String, dynamic>> applyFormSettings(
    String formId,
    Map<String, dynamic> settings,
  ) async {
    if (!isConfigured) {
      return {
        'success': false,
        'error':
            'Apps Script ID not configured. '
            'See scripts/FormSettingsManager.gs for setup instructions.',
      };
    }

    final token = await _authService.getFreshAccessToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    final url = Uri.parse('$_scriptBaseUrl/$_scriptId:run');

    final requestBody = jsonEncode({
      'function': 'applyFormSettings',
      'parameters': [
        {'formId': formId, 'settings': settings},
      ],
      'devMode': false,
    });

    debugPrint('=== APPS SCRIPT: applyFormSettings REQUEST ===');
    debugPrint('URL: $url');
    debugPrint('formId: $formId');
    debugPrint('settings: $settings');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      debugPrint('=== APPS SCRIPT: applyFormSettings RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        // Check for script-level error
        if (jsonData.containsKey('error')) {
          final error = jsonData['error'] as Map<String, dynamic>;
          final errorMessage =
              error['message'] as String? ?? 'Unknown script error';
          debugPrint('=== APPS SCRIPT ERROR: $errorMessage ===');
          return {'success': false, 'error': errorMessage};
        }

        // Extract the script function's return value
        final scriptResponse = jsonData['response'] as Map<String, dynamic>?;
        if (scriptResponse != null) {
          if (scriptResponse.containsKey('result')) {
            final result = scriptResponse['result'] as Map<String, dynamic>;
            return {
              'success': result['success'] as bool? ?? false,
              'applied': result['applied'] as List<dynamic>? ?? [],
              'errors': result['errors'] as List<dynamic>?,
              'error': result['error'] as String?,
            };
          }
        }

        return {
          'success': true,
          'applied': [],
          'error': 'Unexpected response format',
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'error':
              'Permission denied. Make sure the Apps Script is deployed '
              'with "Execute as: Me" and the Google Forms scope is authorized.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error':
              'Script not found. Check the Script ID in '
              'apps_script_service.dart.',
        };
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final errMsg =
            body['error']?['message'] as String? ??
            'HTTP ${response.statusCode}';
        return {'success': false, 'error': errMsg};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get current form settings via Apps Script.
  ///
  /// Returns a map with:
  /// - 'success': bool
  /// - 'settings': `Map<String, dynamic>`? (current settings)
  /// - 'error': String?
  Future<Map<String, dynamic>> getFormSettings(String formId) async {
    if (!isConfigured) {
      debugPrint('=== APPS SCRIPT: getFormSettings SKIP - not configured ===');
      return {'success': false, 'error': 'Apps Script ID not configured.'};
    }

    final token = await _authService.getFreshAccessToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    final url = Uri.parse('$_scriptBaseUrl/$_scriptId:run');

    final requestBody = jsonEncode({
      'function': 'getFormSettings',
      'parameters': [
        {'formId': formId},
      ],
      'devMode': false,
    });

    debugPrint('=== APPS SCRIPT: getFormSettings REQUEST ===');
    debugPrint('URL: $url');
    debugPrint('formId: $formId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      debugPrint('=== APPS SCRIPT: getFormSettings RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        // Check for script-level error
        if (jsonData.containsKey('error')) {
          final error = jsonData['error'] as Map<String, dynamic>;
          final errorMessage =
              error['message'] as String? ?? 'Unknown script error';
          debugPrint(
            '=== APPS SCRIPT: getFormSettings SCRIPT ERROR: $errorMessage ===',
          );
          return {'success': false, 'error': errorMessage};
        }

        final scriptResponse = jsonData['response'] as Map<String, dynamic>?;
        debugPrint(
          '=== APPS SCRIPT: getFormSettings scriptResponse: $scriptResponse ===',
        );

        if (scriptResponse != null && scriptResponse.containsKey('result')) {
          final result = scriptResponse['result'] as Map<String, dynamic>;
          debugPrint('=== APPS SCRIPT: getFormSettings result: $result ===');
          return {
            'success': result['success'] as bool? ?? false,
            'settings': result['settings'] as Map<String, dynamic>?,
            'error': result['error'] as String?,
          };
        }

        debugPrint(
          '=== APPS SCRIPT: getFormSettings UNEXPECTED FORMAT - no response/result key ===',
        );
        debugPrint('jsonData keys: ${jsonData.keys.toList()}');
        return {
          'success': false,
          'error': 'Unexpected response format: ${jsonData.keys.toList()}',
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'error':
              'Permission denied. Make sure the Apps Script is deployed '
              'with "Execute as: Me" and authorized.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Script not found. Check the Script ID.',
        };
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final errMsg =
            body['error']?['message'] as String? ??
            'HTTP ${response.statusCode}';
        return {'success': false, 'error': errMsg};
      }
    } catch (e) {
      debugPrint('=== APPS SCRIPT: getFormSettings EXCEPTION: $e ===');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Link a Google Form's responses to a Google Spreadsheet.
  ///
  /// After linking, all new form responses will automatically appear as rows
  /// in the spreadsheet. Existing responses are also synced.
  ///
  /// Returns a map with:
  /// - 'success': bool
  /// - 'spreadsheetId': String? (the linked spreadsheet ID)
  /// - 'error': String?
  Future<Map<String, dynamic>> linkFormToSheet(
    String formId,
    String spreadsheetId,
  ) async {
    if (!isConfigured) {
      return {
        'success': false,
        'error': 'Apps Script ID not configured.',
      };
    }

    final token = await _authService.getFreshAccessToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    final url = Uri.parse('$_scriptBaseUrl/$_scriptId:run');

    final requestBody = jsonEncode({
      'function': 'linkFormToSheet',
      'parameters': [
        {'formId': formId, 'spreadsheetId': spreadsheetId},
      ],
      'devMode': false,
    });

    debugPrint('=== APPS SCRIPT: linkFormToSheet REQUEST ===');
    debugPrint('formId: $formId, spreadsheetId: $spreadsheetId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      debugPrint('=== APPS SCRIPT: linkFormToSheet RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonData.containsKey('error')) {
          final error = jsonData['error'] as Map<String, dynamic>;
          final errorMessage =
              error['message'] as String? ?? 'Unknown script error';
          debugPrint('=== APPS SCRIPT ERROR: $errorMessage ===');
          return {'success': false, 'error': errorMessage};
        }

        final scriptResponse = jsonData['response'] as Map<String, dynamic>?;
        if (scriptResponse != null && scriptResponse.containsKey('result')) {
          final result = scriptResponse['result'] as Map<String, dynamic>;
          return {
            'success': result['success'] as bool? ?? false,
            'spreadsheetId': result['spreadsheetId'] as String?,
            'error': result['error'] as String?,
          };
        }

        return {
          'success': false,
          'error': 'Unexpected response format',
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'error':
              'Permission denied. Make sure the Apps Script is deployed '
              'with "Execute as: Me" and the required scopes are authorized.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Script not found. Check the Script ID.',
        };
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final errMsg =
            body['error']?['message'] as String? ??
            'HTTP ${response.statusCode}';
        return {'success': false, 'error': errMsg};
      }
    } catch (e) {
      debugPrint('=== APPS SCRIPT: linkFormToSheet EXCEPTION: $e ===');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Unlink a Google Form from its response destination spreadsheet.
  ///
  /// Returns a map with:
  /// - 'success': bool
  /// - 'error': String?
  Future<Map<String, dynamic>> unlinkFormFromSheet(String formId) async {
    if (!isConfigured) {
      return {
        'success': false,
        'error': 'Apps Script ID not configured.',
      };
    }

    final token = await _authService.getFreshAccessToken();
    if (token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    final url = Uri.parse('$_scriptBaseUrl/$_scriptId:run');

    final requestBody = jsonEncode({
      'function': 'unlinkFormFromSheet',
      'parameters': [
        {'formId': formId},
      ],
      'devMode': false,
    });

    debugPrint('=== APPS SCRIPT: unlinkFormFromSheet REQUEST ===');
    debugPrint('formId: $formId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      debugPrint('=== APPS SCRIPT: unlinkFormFromSheet RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonData.containsKey('error')) {
          final error = jsonData['error'] as Map<String, dynamic>;
          final errorMessage =
              error['message'] as String? ?? 'Unknown script error';
          return {'success': false, 'error': errorMessage};
        }

        final scriptResponse = jsonData['response'] as Map<String, dynamic>?;
        if (scriptResponse != null && scriptResponse.containsKey('result')) {
          final result = scriptResponse['result'] as Map<String, dynamic>;
          return {
            'success': result['success'] as bool? ?? false,
            'error': result['error'] as String?,
          };
        }

        return {
          'success': false,
          'error': 'Unexpected response format',
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'error':
              'Permission denied. Make sure the Apps Script is deployed '
              'with "Execute as: Me" and the required scopes are authorized.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Script not found. Check the Script ID.',
        };
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final errMsg =
            body['error']?['message'] as String? ??
            'HTTP ${response.statusCode}';
        return {'success': false, 'error': errMsg};
      }
    } catch (e) {
      debugPrint('=== APPS SCRIPT: unlinkFormFromSheet EXCEPTION: $e ===');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
