import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'locale';
  Locale _locale = const Locale('tr'); // Default to Turkish
  late SharedPreferences _prefs;

  Locale get locale => _locale;

  final List<Locale> supportedLocales = const [
    Locale('tr'), // Turkish
    Locale('en'), // English
    Locale('ru'), // Russian
    Locale('ar'), // Arabic
  ];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = _prefs.getString(_localeKey);
    if (savedLocaleCode != null) {
      _locale = Locale(savedLocaleCode);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'ar':
        return 'العربية';
      default:
        return 'Unknown';
    }
  }

  bool isRTL() {
    return _locale.languageCode == 'ar';
  }
}
