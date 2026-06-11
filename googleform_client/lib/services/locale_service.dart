import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app locale preference and runtime language switching.
class LocaleService {
  LocaleService._();

  static final LocaleService instance = LocaleService._();

  static const _prefKey = 'app_locale';

  /// Supported locales in the app.
  static const supportedLocales = [
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale('pt'),
    Locale('id'),
    Locale('ru'),
    Locale('de'),
    Locale('fr'),
  ];

  static const _traditionalChinese = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  );

  static const _portuguese = Locale('pt');

  /// Notifies listeners when the active locale changes.
  final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

  bool _initialized = false;

  /// Initialize from persisted preference. Call before runApp.
  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved == null || saved.isEmpty || saved == 'system') {
      localeNotifier.value = null;
    } else {
      localeNotifier.value = _localeFromCode(saved);
    }
    _initialized = true;
  }

  /// Returns the locale to use for [MaterialApp.locale].
  /// Priority: user preference -> device locale (if supported) -> English.
  Locale resolveLocale(Locale? deviceLocale) {
    final preferred = localeNotifier.value;
    if (preferred != null) {
      return preferred;
    }
    if (deviceLocale != null) {
      final resolved = _matchSupported(deviceLocale);
      if (resolved != null) return resolved;
    }
    return const Locale('en');
  }

  /// Resolved locale for the current platform language and user preference.
  Locale activeLocale([Locale? deviceLocale]) {
    return resolveLocale(deviceLocale ?? PlatformDispatcher.instance.locale);
  }

  /// Whether the app follows the device locale instead of a fixed choice.
  bool get followsSystem => localeNotifier.value == null;
  /// Persist and apply a locale choice.
  /// Pass `null` to follow system default.
  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.setString(_prefKey, 'system');
    } else {
      await prefs.setString(_prefKey, _codeFromLocale(locale));
    }
    localeNotifier.value = locale;
  }

  /// Human-readable label for the current preference.
  String currentPreferenceLabel({
    required String systemDefaultLabel,
    required String englishLabel,
    required String japaneseLabel,
    required String simplifiedChineseLabel,
    required String traditionalChineseLabel,
    required String portugueseBrazilLabel,
    required String indonesianLabel,
    required String russianLabel,
    required String germanLabel,
    required String frenchLabel,
  }) {
    final preferred = localeNotifier.value;
    if (preferred == null) return systemDefaultLabel;
    switch (preferred.languageCode) {
      case 'ja':
        return japaneseLabel;
      case 'zh':
        return _isTraditionalChinese(preferred)
            ? traditionalChineseLabel
            : simplifiedChineseLabel;
      case 'pt':
        return portugueseBrazilLabel;
      case 'id':
        return indonesianLabel;
      case 'ru':
        return russianLabel;
      case 'de':
        return germanLabel;
      case 'fr':
        return frenchLabel;
      case 'en':
        return englishLabel;
      default:
        return englishLabel;
    }
  }

  static bool _isTraditionalChinese(Locale locale) {
    if (locale.languageCode != 'zh') return false;
    final script = locale.scriptCode;
    final country = locale.countryCode?.toUpperCase();
    return script == 'Hant' ||
        country == 'HANT' ||
        country == 'TW' ||
        country == 'HK' ||
        country == 'MO';
  }

  static Locale? _matchSupported(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return const Locale('ja');
      case 'en':
        return const Locale('en');
      case 'zh':
        return _resolveChineseLocale(locale);
      case 'pt':
        return _portuguese;
      case 'id':
        return const Locale('id');
      case 'ru':
        return const Locale('ru');
      case 'de':
        return const Locale('de');
      case 'fr':
        return const Locale('fr');
      default:
        return null;
    }
  }

  static Locale _resolveChineseLocale(Locale locale) {
    final script = locale.scriptCode;
    final country = locale.countryCode?.toUpperCase();

    if (script == 'Hant' ||
        country == 'TW' ||
        country == 'HK' ||
        country == 'MO') {
      return _traditionalChinese;
    }
    if (script == 'Hans' || country == 'CN' || country == 'SG') {
      return const Locale('zh');
    }
    // Generic zh without script: prefer region, else Simplified.
    if (country == 'TW' || country == 'HK' || country == 'MO') {
      return _traditionalChinese;
    }
    return const Locale('zh');
  }

  static Locale _localeFromCode(String code) {
    switch (code) {
      case 'ja':
        return const Locale('ja');
      case 'zh':
        return const Locale('zh');
      case 'zh_Hant':
        return _traditionalChinese;
      case 'pt_BR':
        return _portuguese;
      case 'id':
        return const Locale('id');
      case 'ru':
        return const Locale('ru');
      case 'de':
        return const Locale('de');
      case 'fr':
        return const Locale('fr');
      case 'en':
      default:
        return const Locale('en');
    }
  }

  static String _codeFromLocale(Locale locale) {
    if (locale.languageCode == 'zh') {
      return _isTraditionalChinese(locale) ? 'zh_Hant' : 'zh';
    }
    if (locale.languageCode == 'pt') {
      return 'pt';
    }
    return locale.languageCode;
  }
}
